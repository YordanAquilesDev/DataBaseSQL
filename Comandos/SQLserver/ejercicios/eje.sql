create database Yordan;
use Yordan;

create table Pedido(
idPedido int primary key identity(1,1),
idCliente int references Cliente(idCliente),
fecha date,
total decimal
);



create table Cliente(
idCliente int primary key identity(1,1),
nombre varchar(60),
apellido varchar(30),
);

create table productos(
idProducto int primary key identity(1,1),
nombre varchar(30),
descripcion varchar(50),
);


create table detalle_pedido(
  idPedido int  references Pedido(idPedido),
  idProducto int references Productos(idProducto)
);
alter table detalle_pedido add cantidad int;
-- ejercicio uno
select p.idPedido,c.nombre,p.fecha,p.total
from Pedido p
join  Cliente c on p.idCliente=p.idCliente
order by p.total desc;


-- ejercicio dos
select c.nombre,p.idPedido,pr.descripcion,d.cantidad
from detalle_pedido d
join Productos pr on d.idProducto=pr.idProducto
join Pedido p on d.idPedido=p.idPedido
join Cliente c  on c.idCliente= p.idCliente
where c.nombre='yordan';

--ejercicio 3
alter table productos add categoria varchar(30);
select * from productos;

select pr.categoria,count(d.cantidad)AS cantidad ,count(p.total) As totalVendido
from detalle_pedido d
join Pedido p on d.idPedido= p.idPedido
join productos pr on d.idProducto=pr.idProducto
group by pr.categoria;

