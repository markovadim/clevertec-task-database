--Вывести к каждому самолету класс обслуживания и количество мест этого класса
select air.aircraft_code, air.model, s.fare_conditions, count(s.fare_conditions)
from aircrafts as air
         join seats as s
              on air.aircraft_code = s.aircraft_code
group by air.aircraft_code, air.model, s.fare_conditions
order by aircraft_code;

--Найти 3 самых вместительных самолета (модель + кол-во мест)
select air.model, count(s.aircraft_code) as seats
from aircrafts as air
         join
     seats as s
     on air.aircraft_code = s.aircraft_code
group by air.model
order by seats desc limit 3;

--Вывести код,модель самолета и места не эконом класса для самолета 'Аэробус A321-200' с сортировкой по местам
select air.aircraft_code, air.model, s.seat_no
from aircrafts as air
         join
     seats as s
     on air.model = 'Аэробус A321-200'
         and not s.fare_conditions = 'Economy'
order by s.seat_no;

--Вывести города в которых больше 1 аэропорта ( код аэропорта, аэропорт, город)
select city
from airports
group by city
having count(city) > 1;

-- Найти ближайший вылетающий рейс из Екатеринбурга в Москву, на который еще не завершилась регистрация
select fl.flight_id,
       fl.flight_no,
       fl.scheduled_departure,
       fl.status
from flights as fl
         join airports
              on (departure_airport = (select airport_code from airports where city = 'Екатеринбург')
                  and (arrival_airport in (select airport_code from airports where city = 'Москва'))
                  and (fl.scheduled_departure::date - bookings.now()::date >= 0)
                  and (fl.status in ('On Time', 'Delayed')))
order by scheduled_departure::date - bookings.now()::date limit 1;

--Вывести самый дешевый и дорогой билет и стоимость ( в одном результирующем ответе)
(select ticket_no, (select min(amount) from ticket_flights) as price from ticket_flights limit 1)
union
(select ticket_no, (select max(amount) from ticket_flights) as price from ticket_flights limit 1)

-- Написать DDL таблицы Customers , должны быть поля id , firstName, LastName, email , phone. Добавить ограничения на поля ( constraints) .
create table if not exists Customers (
    id bigserial primary key,
    firstName varchar(50) not null,
    lastName varchar(50),
    email varchar(50) unique check(email like '%_@.%'),
    phone varchar(50) unique
);

-- Написать DDL таблицы Orders , должен быть id, customerId,	quantity. Должен быть внешний ключ на таблицу customers + ограничения
create table if not exists Orders (
    id bigserial primary key,
    customerId int not null,
    quantity int,
    foreign key (customerId) references bookings.customers(id)
);

-- Написать 5 insert в эти таблицы
insert into customers (id, firstName, lastName, email, phone)
values (1, 'Ivan','Ivanov','ivan@.mail.ru','80334657639'),
       (2, 'Petr','Petrov','yegfb@.mail.ru','80298756473'),
       (3, 'Kirill','Kirillov','cvc54@.mail.ru','8033342256'),
       (4, 'Semen','Semenov','sekmref@.mail.ru','8029112345'),
       (5, 'Maxim','Maximov','man32jfd@.mail.ru','8029654432');

insert into orders (id, customerId, quantity)
values (1, 1, 123),
       (2, 2, 32),
       (3, 5, 1),
       (4, 3, 3),
       (5, 3, 6);

-- удалить таблицы
drop table customers, orders;

-- Вывести свободные места класса комфорт рейсов для регистрации (не включая задержек рейса) из Санкт-Петербурга в Краснодар на неделю вперед

select s.seat_no, f.scheduled_departure
from flights as f
         join airports as air
              on (f.status = 'On Time')
                  and (f.scheduled_departure::date - bookings.now()::date between 0 and 7)
                  and (air.city = 'Санкт-Петербург')
                  and (f.arrival_airport in (select airport_code from airports where city = 'Краснодар'))
         join seats as s on (s.fare_conditions = 'Comfort')
order by f.scheduled_departure