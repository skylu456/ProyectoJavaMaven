select 'drop table', table_name, 'cascade constraints;' from user_tables;

CREATE TABLE CATEGORIA_TEL(id_cat_tel int primary key not null, 
cat_telefono varchar2(15));

CREATE TABLE CATEGORIA_EMAIL(id_cat_email int primary key not null,
cat_email varchar2(15));

CREATE TABLE Telefonos(id_cat_tel int not null, id_tel int not null,
telefono varchar2(20),
CONSTRAINT pk_unified_tel PRIMARY KEY(id_cat_tel, id_tel),
CONSTRAINT fk_tel FOREIGN KEY(id_cat_tel) REFERENCES categoria_tel(id_cat_tel));

CREATE TABLE Email(id_cat_email int not null, id_email int not null,
email varchar2(40),CONSTRAINT pk_unif_email PRIMARY KEY(id_cat_email, id_email),
CONSTRAINT fk_email FOREIGN KEY(id_cat_email) REFERENCES categoria_email(id_cat_email));

CREATE TABLE  Cat_Trabajador(id_cat int primary key not null , categoria varchar2(15));

CREATE TABLE Vendedores(id_vendedor int primary key not null, nombre varchar2(30),
apellido varchar2(30));

CREATE TABLE Contadores(id_contador int primary key not null, id_planilla int not null,
nombre varchar2(40), apellido varchar2(40));

CREATE TABLE Cliente( id_cliente int primary key not null, id_vendedor int not null,
nombre varchar2(40), apellido varchar2(40), nombreNegocio varchar2(40), id_tel int not null,
id_email int not null, direccion varchar2(50), cat_tel int not null, cat_email int not null,
CONSTRAINT fk_client FOREIGN KEY(id_vendedor) REFERENCES Vendedores(id_vendedor),
CONSTRAINT fk_client2 FOREIGN KEY(id_tel,cat_tel) REFERENCES Telefonos(id_tel,id_cat_tel),
CONSTRAINT fk_client3 FOREIGN KEY(id_email,cat_email) REFERENCES Email(id_email,id_cat_email));

CREATE TABLE Empleados(id_empleado int primary key not null, nombre varchar2(40),
apellido varchar2(40), salarioBase number(38,2), cargo varchar2(40), id_tel int not null,
id_email int not null, cat_tel int not null, cat_email int not null,
CONSTRAINT fk_emp FOREIGN KEY(id_tel,cat_tel) REFERENCES telefonos(id_tel,id_cat_tel),
CONSTRAINT fk_emp2 FOREIGN KEY(id_email,cat_email) REFERENCES Email(id_email,id_cat_email));


CREATE TABLE Planilla(id_planilla int primary key not null, salarioBruto number(38,2) not null,
fechaIngreso date, apellido varchar2(40), nombre varchar2(40), id_empleado int,
id_vendedor int,prestaciones number(38,2), salarioNeto number(38,2), id_cat int not null,
CONSTRAINT fk_planilla FOREIGN KEY(id_empleado) REFERENCES Empleados(id_empleado),
CONSTRAINT fk_planilla2 FOREIGN KEY(id_vendedor) REFERENCES Vendedores(id_vendedor));

CREATE TABLE Proveedores(id_proveedor int primary key not null, id_empleado int not null,
nombre varchar2(40), apellido varchar2(40), nombreEmpresa varchar2(15), id_tel int not null,
id_email int not null, direccion varchar2(100),cat_tel int not null, cat_email int not null,
CONSTRAINT fk_prov FOREIGN KEY(id_empleado) REFERENCES Empleados(id_empleado),
CONSTRAINT fk_prov2 FOREIGN KEY(id_tel,cat_tel) REFERENCES telefonos(id_tel,id_cat_tel),
CONSTRAINT fk_prov3 FOREIGN KEY(id_email,cat_email) REFERENCES Email(id_email,id_cat_email));

CREATE TABLE Pago_empleado(id_empleado int not null, id_contador int not null, 
pago number(38,2) not null, estado_prest varchar2(40),
CONSTRAINT pk_payE PRIMARY KEY(id_empleado, id_contador),
CONSTRAINT fk_payE FOREIGN KEY(id_empleado) REFERENCES Empleados(id_empleado),
CONSTRAINT fk_payE2 FOREIGN KEY(id_contador) REFERENCES Contadores(id_contador)); 

CREATE TABLE Pago_Vendedor(id_vendedor int not null, id_contador int not null, 
pago number(38,2) not null, estado_prest varchar2(40),
CONSTRAINT pk_payV PRIMARY KEY(id_vendedor, id_contador),
CONSTRAINT fk_payV FOREIGN KEY(id_vendedor) REFERENCES Vendedores(id_vendedor),
CONSTRAINT fk_payV2 FOREIGN KEY(id_contador) REFERENCES Contadores(id_contador)); 

CREATE TABLE Inventario( id_producto int primary key not null, id_empleado int not null, 
categoria varchar2(10), cantidad number, descripcion varchar2(100), id_proveedor int not null,
CONSTRAINT fk_inv FOREIGN KEY(id_empleado) REFERENCES Empleados(id_empleado),
CONSTRAINT fk_inv2 FOREIGN KEY(id_proveedor) REFERENCES Proveedores(id_proveedor));

CREATE TABLE Cotizaciones(id_cotizacion int primary key not null, fechaCotizacion date,
monto number(38,2), id_cliente int not null, id_producto  int not null, cantidad number(38,2), 
CONSTRAINT fk_cot FOREIGN KEY(id_cliente) REFERENCES Cliente(id_cliente),
CONSTRAINT fk_cot2 FOREIGN KEY(id_producto) REFERENCES Inventario(id_producto));

CREATE TABLE EfectuarCotizacion(id_cotizacion int not null, id_vendedor int not null,
total number(38,2),
CONSTRAINT pk_realize_cot PRIMARY KEY(id_cotizacion, id_vendedor),
CONSTRAINT fk_realize_cot2 FOREIGN KEY(id_cotizacion) REFERENCES Cotizaciones(id_cotizacion),
CONSTRAINT fk_realize_cot3 FOREIGN KEY(id_vendedor) REFERENCES Vendedores(id_vendedor));

CREATE TABLE Factura(id_factura int primary key not null, id_cotizacion int not null,
subTotal number(38,2), total number(38,2), id_cliente int not null,
CONSTRAINT fk_factura FOREIGN KEY(id_cotizacion) REFERENCES Cotizaciones(id_cotizacion),
CONSTRAINT fk_factura2 FOREIGN KEY(id_cliente) REFERENCES Cliente(id_cliente));

CREATE TABLE EfectuarFactura( id_factura int not null, id_contador int not null,
total number(38,2),
CONSTRAINT pk_efec_pay PRIMARY KEY(id_factura, id_contador),
CONSTRAINT fk_efec_pay2 FOREIGN KEY(id_factura) REFERENCES Factura(id_factura));


--PL SQL

drop sequence auto_seq;
CREATE SEQUENCE auto_seq
START WITH 1
INCREMENT BY 1;

CREATE OR REPLACE PROCEDURE addCategorias(
p_idCatEmail IN categoria_email.id_cat_email%TYPE,
p_idCatTel IN categoria_tel.id_cat_tel%TYPE,
p_categoryTel  IN categoria_tel.cat_telefono%TYPE,
p_categoryEmail IN categoria_email.cat_email%TYPE,
p_idWork IN Cat_Trabajador.id_cat%TYPE,
p_cat IN Cat_Trabajador.categoria%TYPE
)AS
BEGIN
    INSERT INTO categoria_email VALUES(p_idCatEmail,p_categoryEmail);
    INSERT INTO categoria_tel VALUES(p_idCatTel, p_categoryTel);
    INSERT INTO Cat_Trabajador VALUES(p_idWork, p_cat);
EXCEPTION 
    WHEN program_error THEN 
    dbms_output.put_line('Hubo un error en el PL/SQL. Vuelve a intentarlo.');
    WHEN dup_val_on_index THEN 
    DBMS_OUTPUT.PUT_LINE('Hubo un error de duplicación. Revisa los parametros.');
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error desconocido.'||'SQLCODE');
END AddCategorias;

DECLARE
    TYPE varrayTipos IS VARRAY(4) of VARCHAR2(15);
    TYPE arrayTiposTrabajadores IS VARRAY(4) of VARCHAR2(20);
    v_Tipos  varrayTipos;
    v_Trabajadores arrayTiposTrabajadores;
    v_counter number(38,0);
BEGIN
    v_Tipos := varrayTipos('Cliente', 'Empleados', 'Vendedores', 'Proveedor');
    v_Trabajadores := arrayTiposTrabajadores('Contador', 'Vendedor', 'Empleado', 'Otro');
    FOR v_counter IN 1..4 LOOP
    addCategorias( v_counter, v_counter,v_Tipos(v_counter),v_Tipos(v_counter)
    ,v_counter, v_Trabajadores(v_counter) );
    END LOOP;
END;

CREATE OR REPLACE PROCEDURE addTelEmail(
p_idCat_tel IN telefonos.id_cat_tel%TYPE,
p_idTel IN telefonos.id_tel%TYPE,
p_tel  IN Telefonos.telefono%TYPE,
p_idCat_email IN email.id_cat_email%TYPE,
p_id_email IN email.id_email%TYPE,
p_email  IN email.email%TYPE
)AS
BEGIN
    INSERT INTO Telefonos VALUES(p_idCat_tel,p_idTel, p_tel);
    INSERT INTO Email VALUES(p_idCat_email, p_id_email, p_email);
EXCEPTION 
    WHEN program_error THEN 
    dbms_output.put_line('Hubo un error en el PL/SQL. Vuelve a intentarlo.');
    WHEN dup_val_on_index THEN 
    DBMS_OUTPUT.PUT_LINE('Hubo un error de duplicación. Revisa los parametros.');
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error desconocido.'||SQLCODE);
END AddTelEmail;

BEGIN
    AddTelEmail(1,1,'235-8500',1,1,'xymena_223@domain.com');
    AddTelEmail(2,2,'378-1400',2,2,'ml27@gmg.com');
    AddTelEmail(3,3,'630-58914',3,3,'raulAt@gmg.com');
    AddTelEmail(3,4,'478-2000',3,4,'lt_n25@gmg.com');
    AddTelEmail(4,5,'992-1550',4,5,'Ikauz@ashLimites.fr');
END; 

CREATE OR REPLACE PROCEDURE addVendedores(
p_id_Vend IN Vendedores.id_vendedor%TYPE,
p_name IN Vendedores.nombre%TYPE,
p_surname IN Vendedores.apellido%TYPE)AS
BEGIN
    INSERT INTO Vendedores VALUES(p_id_Vend, p_name, p_surname);
EXCEPTION 
    WHEN program_error THEN 
    dbms_output.put_line('Hubo un error en el PL/SQL. Vuelve a intentarlo.');
    WHEN dup_val_on_index THEN 
    DBMS_OUTPUT.PUT_LINE('Hubo un error de duplicación. Revisa los parametros.');
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error desconocido.'||'SQLCODE');
END addVendedores;

BEGIN
    addVendedores(1,'Raul','Altamaria');
    addVendedores(2,'Laura','Tenaz');
END;

CREATE OR REPLACE PROCEDURE AddNewEmp(
p_idEmp IN  Empleados.ID_EMPLEADO%TYPE,
p_name IN Empleados.nombre%TYPE,
p_surname IN Empleados.apellido%TYPE,
p_BSalary IN Empleados.salarioBase%TYPE,
p_Cargo IN Empleados.cargo%TYPE,
p_idEmail IN Empleados.id_Email%TYPE,
p_idTel IN Empleados.id_Tel%TYPE,
p_catTel IN Empleados.cat_tel%TYPE,
p_catEmail IN Empleados.cat_email %TYPE)AS
BEGIN
    INSERT INTO Empleados VALUES(p_idEmp,
     p_name,p_surname,p_BSalary,p_Cargo,p_idTel,p_idEmail,p_catTel
    ,p_catEmail);
EXCEPTION 
    WHEN program_error THEN 
    dbms_output.put_line('Hubo un error en el PL/SQL. Vuelve a intentarlo.');
    WHEN dup_val_on_index THEN 
    DBMS_OUTPUT.PUT_LINE('Hubo un error de duplicación. Revisa los parametros.');
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error desconocido.'||SQLCODE);
END AddNewEmp;  

BEGIN
    AddNewEmp(1,'Mario','Truemann',1100,'Encargado de Inventario',2,2,2,2);
END;

CREATE OR REPLACE FUNCTION calcNetSalary(
p_prest IN Planilla.prestaciones%TYPE,
p_base IN Planilla.salarioBruto%TYPE)RETURN NUMBER IS
v_newSalary number;
BEGIN
    v_newSalary := (p_prest*p_base)+p_base;
    RETURN v_newSalary;
END;


    
CREATE OR REPLACE PROCEDURE AddNewPlanilla(
p_id_Plan IN Planilla.id_planilla%TYPE,
p_BSalary IN Planilla.salarioBruto%TYPE,
p_date IN Planilla.fechaIngreso%TYPE,
p_surname IN Planilla.apellido%TYPE,
p_name IN Planilla.nombre%TYPE,
p_prest IN Planilla.prestaciones%TYPE,
p_id_Emp IN Planilla.id_empleado%TYPE,
p_id_V IN Planilla.id_vendedor%TYPE,
p_id_cat IN Planilla.id_cat%TYPE)AS
v_Salary number;
BEGIN
    v_Salary := 0;
    v_Salary := calcNetSalary(p_prest,p_BSalary);
    IF p_id_cat = 1 THEN
        INSERT INTO Planilla(id_planilla, salarioBruto, fechaIngreso,
        apellido,nombre, prestaciones, salarioneto,id_empleado, id_cat)
        VALUES(p_id_Plan,p_BSalary,p_date,p_surname,p_name,
        p_prest,v_Salary, p_id_Emp,p_id_cat);
    ELSIF p_id_cat = 2 THEN
        INSERT INTO Planilla(id_planilla, salarioBruto, fechaIngreso,
        apellido,nombre, prestaciones, salarioneto,id_vendedor, id_cat)
        VALUES(p_id_Plan,p_BSalary,p_date,p_surname,p_name,
        p_prest,v_Salary, p_id_V,p_id_cat);
    END IF;
EXCEPTION 
    WHEN program_error THEN 
    dbms_output.put_line('Hubo un error en el PL/SQL. Vuelve a intentarlo.');
    WHEN dup_val_on_index THEN 
    DBMS_OUTPUT.PUT_LINE('Hubo un error de duplicación. Revisa los parametros.');
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error desconocido.'||SQLCODE);
END AddNewPlanilla;

BEGIN
    ADDNewPlanilla(1,1100,'11-JUN-2010', 'Truemann','Mario',210.25,1,null,1);
END;

CREATE OR REPLACE PROCEDURE AddNewContadores(
p_idContador IN  Contadores.id_contador%TYPE,
p_name IN Contadores.nombre%TYPE,
p_surname IN Contadores.apellido%TYPE,
p_idPlanilla IN Contadores.id_planilla%TYPE)AS
BEGIN
    INSERT INTO Contadores VALUES(p_idContador,p_idPlanilla,p_name,p_surname );
EXCEPTION 
    WHEN program_error THEN 
    dbms_output.put_line('Hubo un error en el PL/SQL. Vuelve a intentarlo.');
    WHEN dup_val_on_index THEN 
    DBMS_OUTPUT.PUT_LINE('Hubo un error de duplicación. Revisa los parametros.');
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error desconocido.'||SQLCODE);
END AddNewContadores;
    
BEGIN
    AddNewContadores(1,'Riel', 'Smith', 1);
END;

CREATE OR REPLACE PROCEDURE AddNewCliente(
p_idClient IN  Cliente.ID_CLIENTE%TYPE,
p_idVendor IN Cliente.id_vendedor%TYPE,
p_name IN Cliente.nombre%TYPE,
p_surname IN Cliente.apellido%TYPE,
p_nameNegocio IN Cliente.nombreNegocio%TYPE,
p_idTel IN Cliente.ID_TEL%TYPE,
p_idEmail IN Cliente.ID_EMAIL%TYPE,
p_Direc IN Cliente.Direccion%TYPE,
p_catTel IN Cliente.cat_tel%TYPE,
p_catEmail IN Cliente.cat_email%TYPE)AS
BEGIN
    INSERT INTO Cliente VALUES(p_idClient,
    p_idVendor,p_name,p_surname,p_nameNegocio,p_idTel,p_idEmail,p_Direc,p_catTel
    ,p_catEmail);
EXCEPTION 
    WHEN program_error THEN 
    dbms_output.put_line('Hubo un error en el PL/SQL. Vuelve a intentarlo.');
    WHEN dup_val_on_index THEN 
    DBMS_OUTPUT.PUT_LINE('Hubo un error de duplicación. Revisa los parametros.');
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error desconocido.'||SQLCODE);
END AddNewCliente;

BEGIN
    AddNewCliente(1,1,'Xymena','Robles','Kazua Rt INC', 1, 1, 
    'M. 1581 Via Brasil',1,1);
END;

CREATE OR REPLACE PROCEDURE AddNewProviders(
p_idProv IN  Proveedores.ID_proveedor%TYPE,
p_idEmp IN Proveedores.id_empleado%TYPE,
p_name IN Proveedores.nombre%TYPE,
p_surname IN Proveedores.apellido%TYPE,
p_nameEmpresa IN Proveedores.nombreEmpresa%TYPE,
p_Direccion IN Proveedores.direccion%TYPE,
p_idEmail IN Proveedores.id_Email%TYPE,
p_idTel IN Proveedores.id_Tel%TYPE,
p_catTel IN Proveedores.cat_tel%TYPE,
p_catEmail IN Proveedores.cat_email %TYPE)AS
BEGIN
    INSERT INTO Proveedores VALUES(p_idProv,
     p_idEmp,p_name,p_surname,p_nameEmpresa,p_idTel,p_idEmail,p_Direccion,p_catTel
    ,p_catEmail);
EXCEPTION 
    WHEN program_error THEN 
    dbms_output.put_line('Hubo un error en el PL/SQL. Vuelve a intentarlo.');
    WHEN dup_val_on_index THEN 
    DBMS_OUTPUT.PUT_LINE('Hubo un error de duplicación. Revisa los parametros.');
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error desconocido.'||SQLCODE);
END AddNewProviders;  

BEGIN
    AddNewProviders(1,1,'Ulua', 'Raymundo','ASH Gmbh','K258 HB Burlesque Lyon 5328 FR',5,
   5,4,4);
END;



CREATE OR REPLACE PROCEDURE AddProductos(
p_idProduct IN Inventario.id_producto%TYPE,
p_idEmp IN Inventario.id_empleado%TYPE,
p_categoria IN Inventario.categoria%TYPE,
p_cantidad IN Inventario.cantidad%TYPE,
p_desc IN Inventario.Descripcion%TYPE,
p_prov IN Inventario.id_proveedor%TYPE)AS
BEGIN
    INSERT INTO Inventario VALUES(p_idProduct,p_idEmp,p_categoria,p_cantidad,
    p_desc,p_prov);
EXCEPTION 
    WHEN program_error THEN 
    dbms_output.put_line('Hubo un error en el PL/SQL. Vuelve a intentarlo.');
    WHEN dup_val_on_index THEN 
    DBMS_OUTPUT.PUT_LINE('Hubo un error de duplicación. Revisa los parametros.');
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error desconocido.'||SQLCODE);
END AddProductos;  

BEGIN
    AddProductos(1,1,'Limpieza',142,'Fabuloso 2MT 400CML',1);
END;
CREATE OR REPLACE PROCEDURE NewCotizacion(
p_idCotizacion IN  Cotizaciones.Id_cotizacion%TYPE,
p_fecha IN  Cotizaciones.fechaCotizacion%TYPE,
p_monto IN Cotizaciones.monto%TYPE,
p_idClient IN Cotizaciones.id_cliente%TYPE,
p_idProd IN Cotizaciones.id_producto%TYPE,
p_cant IN Cotizaciones.cantidad%TYPE)AS
BEGIN
    INSERT INTO Cotizaciones VALUES(p_idCotizacion,p_fecha,p_monto,p_idClient,
    p_idProd,p_cant);
EXCEPTION 
    WHEN program_error THEN 
    dbms_output.put_line('Hubo un error en el PL/SQL. Vuelve a intentarlo.');
    WHEN dup_val_on_index THEN 
    DBMS_OUTPUT.PUT_LINE('Hubo un error de duplicación. Revisa los parametros.');
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error desconocido.'||SQLCODE);
END NewCotizacion;
BEGIN
    NewCotizacion(1,sysdate,530,1,1,14);
END;


CREATE OR REPLACE PROCEDURE Facturizacion(
p_idFactura IN  Factura.Id_factura%TYPE,
p_idCotizacion IN Factura.Id_cotizacion%TYPE,
p_subtotal IN Factura.subtotal%TYPE,
p_total IN Factura.total%TYPE,
p_idClient IN Factura.Id_Cliente%TYPE)AS
BEGIN
    INSERT INTO Factura VALUES(p_idFactura,p_idCotizacion ,p_subtotal ,p_total,
    p_idClient);
EXCEPTION 
    WHEN program_error THEN 
    dbms_output.put_line('Hubo un error en el PL/SQL. Vuelve a intentarlo.');
    WHEN dup_val_on_index THEN 
    DBMS_OUTPUT.PUT_LINE('Hubo un error de duplicación. Revisa los parametros.');
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error desconocido.'||SQLCODE);
END Facturizacion;

BEGIN
    Facturizacion(1,1,500.00, 575.25,1);
END;

CREATE OR REPLACE TRIGGER PayVendEmp
AFTER UPDATE ON Planilla
FOR EACH ROW
DECLARE
    CURSOR c_Payments IS
    SELECT  z.id_planilla, z.id_contador
    FROM Contadores z;
    v_Payment c_Payments%ROWTYPE;
BEGIN
    OPEN c_Payments;
    FETCH c_Payments INTO v_Payment;
    CLOSE c_Payments;
    IF :NEW.prestaciones <=  0 THEN
        INSERT INTO Pago_Vendedor VALUES(auto_seq.nextval, v_Payment.id_contador,
        :new.salarioNeto, 'No hubo prestaciones esta vez.');
        INSERT INTO Pago_Vendedor VALUES(auto_seq.currval, v_Payment.id_contador,
        :new.salarioNeto, 'No hubo prestaciones esta vez.');
    ELSE
        INSERT INTO Pago_Vendedor VALUES(auto_seq.nextval, v_Payment.id_contador,
        :new.salarioNeto, 'Hubo Prestaciones');
        INSERT INTO Pago_Vendedor VALUES(auto_seq.currval, v_Payment.id_contador,
        :new.salarioNeto, 'Hubo Prestaciones.');
    END IF;
END;

CREATE OR REPLACE TRIGGER efecFactura
AFTER INSERT ON Factura 
FOR EACH ROW
BEGIN
    INSERT INTO EfectuarFactura VALUES(:new.id_factura, :new.total);
END;





 /*-----------------------------VISTAS----------------------------------------*/

CREATE VIEW Vista_Cliente as select cli.nombre, cli.apellido,
cli.direccion, ema.email, tel.telefono
FROM Cliente cli
INNER JOIN 
Email ema ON ema.id_email = cli.id_email 
INNER JOIN
Telefonos tel ON tel.id_tel = cli.id_tel;
select * from vista_cliente;            
        
CREATE VIEW  Vista_Pago as select pla.salarioBruto, pla.apellido, pla.nombre, 
pla.salarioNeto, pla.id_empleado, pla.id_vendedor
FROM Planilla pla;

select * from Vista_Pago;

CREATE VIEW Vista_Proveedor as select  inv.cantidad, inv.categoria, inv.descripcion,
pr.nombre, pr.apellido
FROM Inventario inv
INNER JOIN
Proveedores pr ON pr.Id_proveedor = inv.id_proveedor;

select * from Vista_Proveedor;

CREATE VIEW Vista_Completa_Cotizacion as select cot.id_cotizacion AS numero_Cotizacion, 
cot.monto, cot.cantidad, cli.nombre, cli.apellido, zs.descripcion, zs.categoria
FROM Cotizaciones cot 
INNER JOIN 
Cliente cli ON cot.id_cliente = cli.id_cliente 
INNER JOIN
Inventario zs ON zs.id_producto = cot.id_producto;

select * from Vista_Completa_Cotizacion;

