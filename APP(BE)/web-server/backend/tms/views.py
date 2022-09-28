from django.shortcuts import render
from django.db.models import Q
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import permissions, status, filters
from rest_framework.decorators import authentication_classes, api_view
from .utils import get_user, get_notification, get_reservation, get_reservation_by_booker, get_reservation_by_driver, get_reservation_by_battalion, get_car 
from .serializers import NotificationSerializer, ReservationSerializer, CarSerializer, AvailableCarSerializer
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
from .models import Reservation, Notification, Car
from rest_framework_simplejwt.authentication import JWTAuthentication
import datetime

# ws test - 1
def index(request):
    return render(request, 'index.html')

# ws test - 2
def battalion(request, battalion):
    return render(request, 'battalion.html', {
        'battalion': battalion
    })

class notification(APIView):

    def get(self, request):
        return Response(get_notification())
    
    @swagger_auto_schema(request_body=NotificationSerializer, operation_summary='알림 보내기')
    def post(self, request):    
        serializer = NotificationSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class car(APIView):

    get_params = [
        openapi.Parameter(
            "car_id",
            openapi.IN_QUERY,
            description="car_id",
            type=openapi.TYPE_STRING,
            default=""
    )]
    @swagger_auto_schema(manual_parameters=get_params, operation_summary='차량 정보 얻기', 
                        )
    def get(self, request):
        car_id = request.GET['car_id']
        return Response(get_car(car_id))
    
    @swagger_auto_schema(request_body=CarSerializer, operation_summary='차량 추가하기', operation_description="차량의 id는 부대번호+차량번호로 생성하면 됨")
    def post(self, request):    
        serializer = CarSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    

class reservation(APIView):
    get_params = [
        openapi.Parameter(
            "booker_id",
            openapi.IN_QUERY,
            description="booker_id",
            type=openapi.TYPE_INTEGER,
            default=-1
    ),
        openapi.Parameter(
                "driver_id",
                openapi.IN_QUERY,
                description="driver_id",
                type=openapi.TYPE_INTEGER,
                default=-1
    )
    ,
        openapi.Parameter(
                "reservation_id",
                openapi.IN_QUERY,
                description="reservation_id",
                type=openapi.TYPE_INTEGER,
                default=-1
    )
    ,
        openapi.Parameter(
                "battalion_id",
                openapi.IN_QUERY,
                description="battalion_id",
                type=openapi.TYPE_STRING,
                default=""
    )
    ]
    @swagger_auto_schema(manual_parameters=get_params, operation_summary='배차 예약 정보 얻기', 
                        operation_description='''
                        booker_id에 값을 넣으면 사용자가 신청한 예약을 전부 반환
                        driver_id에 값을 넣으면 사용자가 신청한 예약을 전부 반환
                        reservation_id에 값을 넣으면 그 예약 정보 반환
                        battalion_id에 값을 넣으면 대대에 넣어진 예약 정보 반환
                        하나에만 값을 넣어야 함
                        ''')
    def get(self, request):
        try:
            booker_id = int(request.GET['booker_id'])
            driver_id = int(request.GET['driver_id'])
            reservation_id = int(request.GET['reservation_id'])
            battalion_id = str(request.GET['battalion_id'])

            if booker_id != -1:
                return Response(get_reservation_by_booker(booker_id), status=status.HTTP_200_OK)
            elif driver_id != -1:
                return Response(get_reservation_by_driver(driver_id), status=status.HTTP_200_OK)
            elif battalion_id != "":
                return Response(get_reservation_by_battalion(battalion_id), status=status.HTTP_200_OK)
            elif reservation_id != -1:
                return Response(get_reservation(reservation_id), status=status.HTTP_200_OK)
        except Exception as e:
            print(e)
            return Response(status=status.HTTP_400_BAD_REQUEST)

    @swagger_auto_schema(request_body=ReservationSerializer , operation_summary='배차 예약하기')
    def post(self, request):
        serializer = ReservationSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            battalion_receiver = str(serializer.data["car"])[:4]
            user = get_user(serializer.data["booker"])
            Notification.objects.create(
                user_sender=user,
                battalion_receiver=battalion_receiver,
                permission=1,
                message=f"{user.login_id}이(가) 배차를 신청했습니다."
            )
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    
    @swagger_auto_schema(manual_parameters=[
        openapi.Parameter(
            "reservation_id",
            openapi.IN_QUERY,
            description="reservation_id",
            type=openapi.TYPE_STRING,
            default=""
    )], operation_summary='배차 예약 정보 삭제하기')
    def delete(self, request):
        try: 
            reservation_id = request.GET['reservation_id']
            Reservation.objects.get(id=reservation_id).delete()
            return Response(status=status.HTTP_200_OK)
        except Exception as e:
            print(e)
            return Response(status=status.HTTP_400_BAD_REQUEST)



@swagger_auto_schema(method='post', request_body=openapi.Schema(
          'reservation_id',
          type=openapi.TYPE_OBJECT,
          properties={
              'reservation_id': openapi.Parameter('reservation_id', openapi.IN_BODY, type=openapi.TYPE_STRING)
        },
    ), operation_summary='배차 예약 승인하기')
@api_view(['POST'])
def approve_reservation(request):
    try:
        reservation_id = request.data['reservation_id']
        reservation = Reservation.objects.get(id=reservation_id)
        reservation.is_approved = True
        reservation.save()
        return Response(status=status.HTTP_202_ACCEPTED)
    except Exception as e:
        print(e)
        return Response(status=status.HTTP_400_BAD_REQUEST)

@swagger_auto_schema(method='post', request_body=AvailableCarSerializer , operation_summary='배차 가능한 차량 검색하기')    
@api_view(['POST'])
def get_available_car(request):
    try:
        serializer = AvailableCarSerializer(data=request.data)
        if serializer.is_valid():
            reservation = Reservation.objects.select_related('car').filter(Q(car__id__startswith=serializer.data["battalion"]) &
                                                                           Q(reservation_date__date=datetime.date.today() + datetime.timedelta(days=1)))
            reservation = reservation.values()
            already_reserved = [rv["car_id"] for rv in reservation]
            available_car = Car.objects.filter(
                Q(can_ride__gte=(serializer.data["followers_num"]+2)) &
                ~Q(id__in=already_reserved)
            )
            ret_seriallizer = CarSerializer(available_car, many=True)
            return Response(ret_seriallizer.data, status=status.HTTP_202_ACCEPTED)
        return Response("serilalizer isn't valid",status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        print(e)
        return Response(status=status.HTTP_400_BAD_REQUEST)