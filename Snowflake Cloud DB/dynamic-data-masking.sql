--Login With ACCOUNTADMIN. To Use Below Snowflake version should be Enterprise.
--Step 1 -
CREATE DATABASE FINANCE;
CREATE SCHEMA STAGE;
CREATE TABLE STAGE.CUSTOMER (
    CUSTOMERID INTEGER NOT NULL IDENTITY,
    FULLNAME  VARCHAR(255) NULL,
    EMAILID VARCHAR(255) NULL,
    CITY VARCHAR(255) NULL,
    SSN VARCHAR(13) NULL,
    CREDITCARD VARCHAR(255) NULL,
    DATEOFBIRTH VARCHAR(255),
    PRIMARY KEY (CUSTOMERID)
);

INSERT INTO CUSTOMER( FULLNAME , EMAILID , CITY , SSN , CREDITCARD , DATEOFBIRTH ) VALUES('Chadwick Long','libero@vel.org','Bontang','16700219 2099','372619208674850','10/03/1959'),('Barry White','ultrices.iaculis.odio@atvelitPellentesque.org','Gravelbourg','16631019 8236','341452321269970','11/28/1982'),('Nero Johnston','molestie@dictumeleifend.net','Villa Verde','16930502 2155','372770250004239','04/22/1933'),('Thaddeus Hood','diam.dictum@Etiam.org','Habra','16220325 9524','3481 458458 91872','12/25/1994'),('Keegan Page','per.conubia.nostra@mi.org','Puerto Guzmán','16651018 0828','377643684865746','02/15/1997'),('Jordan Gibson','inceptos@tellusSuspendissesed.org','Gudivada','16330423 6320','3750 277008 54524','11/01/1992'),('Gage Mcmillan','in.consequat.enim@congueelitsed.com','Edmonton','16020722 2787','3403 873493 77002','06/03/1957'),('Andrew Leblanc','semper@placerat.co.uk','Herk-de-Stad','16551204 9718','3444 276445 62852','11/30/1989'),('Brent Clements','tempor@ipsumportaelit.co.uk','Lochristi','16430309 3423','377575623111156','10/11/2001'),('Steven Hooper','imperdiet.dictum.magna@cursus.org','South Burlington','16231108 5886','3429 665990 48039','06/22/1992');
INSERT INTO CUSTOMER( FULLNAME , EMAILID , CITY , SSN , CREDITCARD , DATEOFBIRTH ) VALUES('Gary Baxter','neque.vitae@tellusSuspendissesed.edu','Mahbubnagar','16470802 4486','3752 728387 19062','02/28/1996'),('Raymond Brooks','id@nuncsed.org','Aurangabad','16140314 8727','3762 395417 29547','07/15/1963'),('Simon Lester','Aliquam.rutrum@habitantmorbi.org','Krems an der Donau','16410525 1815','3498 599435 41168','04/22/2008'),('Nicholas Horn','Proin.velit@quislectus.ca','Malakand','16410103 3027','3719 872764 70639','03/09/2003'),('Axel Kemp','Donec.non@ornareliberoat.edu','Ospedaletto Lodigiano','16990728 5424','3711 851665 82171','08/20/1935'),('Chase Delaney','sed.hendrerit.a@elit.ca','Portigliola','16000425 8869','348275164422163','10/26/2004'),('Thor Watkins','dolor.elit.pellentesque@imperdiet.ca','Zhukovsky','16970212 6278','3475 467733 69180','09/09/1975'),('Ezekiel Cruz','Aliquam.nisl@hendreritaarcu.net','Montjovet','16560623 9373','346695054972138','01/18/2017'),('Garth Gibbs','bibendum.fermentum@sapiengravida.net','Shreveport','16061102 0520','379475236880594','09/18/1976'),('Holmes Hinton','sem.elit.pharetra@dis.edu','Paita','16500709 3262','3756 297773 39212','03/04/2012');
INSERT INTO CUSTOMER( FULLNAME , EMAILID , CITY , SSN , CREDITCARD , DATEOFBIRTH ) VALUES('Hilel Norman','feugiat.tellus@tempusscelerisquelorem.edu','Colli a Volturno','16180202 4842','3407 269257 56727','04/11/1941'),('Bert Rowe','placerat.orci@magna.ca','El Monte','16260112 4965','344686031373575','06/12/1998'),('Neil Gillespie','vitae.posuere.at@Loremipsum.com','San Felice a Cancello','16180917 6165','3422 721608 00563','10/12/1995'),('Brenden Baird','montes.nascetur@metus.com','Gwangyang','16460223 3449','376603119707435','02/25/1955'),('Hunter Mccarty','ridiculus.mus@egestasSed.ca','Gooik','16021104 0860','3740 807495 97464','09/08/1985'),('Louis Huff','amet.diam@sapiengravidanon.ca','Thionville','16980811 6769','377916794815888','04/04/1958'),('Connor Underwood','vel.arcu@vitaediam.ca','Barrhead','16491104 5484','341553380184693','10/17/1947'),('Moses Lopez','ridiculus.mus@Proinnislsem.edu','Calgary','16030412 2799','3493 472167 33217','04/27/1960'),('Zeph Wolfe','velit.Pellentesque.ultricies@Nam.net','Huaral','16670128 1906','346629543370141','04/03/1969'),('Myles Weber','sit.amet.massa@congue.edu','Smoky Lake','16070328 1386','3735 269627 81442','02/13/2017');
INSERT INTO CUSTOMER( FULLNAME , EMAILID , CITY , SSN , CREDITCARD , DATEOFBIRTH ) VALUES('Tanek Rodgers','eu.eleifend.nec@Pellentesqueultricies.net','Envigado','16261212 9722','3451 273337 06906','10/21/1950'),('Chancellor Todd','orci.consectetuer.euismod@adipiscing.co.uk','Skardu','16310921 0546','3479 435292 50816','09/11/1968'),('Austin Horton','Donec.nibh.enim@euaugueporttitor.com','Reinbek','16060825 0676','3777 478629 54659','06/17/2008'),('Roth Figueroa','natoque@ametfaucibus.net','Sooke','16840706 7969','345310175594123','03/14/1941'),('Lucas Dennis','quam.quis@viverraMaecenasiaculis.ca','Wansin','16650723 0735','376884737387236','11/10/2000'),('Beau Velez','Nulla.tincidunt.neque@Nulla.ca','Lafayette','16690716 4971','3487 615320 89982','01/11/1956'),('James Finch','tempor.arcu@dis.net','Alto Baudó','16220610 6375','3415 420109 12946','06/13/2019'),('Amir Sullivan','In.nec@non.ca','Acquafondata','16660213 3149','379286602422659','11/17/1932'),('Nolan Cruz','a@egetdictumplacerat.net','Montauban','16180115 1000','3426 921402 53908','10/16/1974'),('Hammett Ayers','euismod.mauris.eu@eu.net','Okara','16900501 5277','372451338747046','02/08/2002');
INSERT INTO CUSTOMER( FULLNAME , EMAILID , CITY , SSN , CREDITCARD , DATEOFBIRTH ) VALUES('Anthony Nieves','dolor@eueleifend.com','Bolzano Vicentino','16471105 2656','343931296633755','03/30/1988'),('Caldwell Mcdaniel','mauris.Morbi.non@congueelit.net','Geel','16630709 3192','3451 139277 09613','07/14/1975'),('Timothy Hinton','erat.Vivamus@Quisque.co.uk','Uribia','16081222 5167','3432 744019 70600','11/15/1931'),('Clinton Watkins','facilisis.vitae.orci@diam.com','Waiuku','16091025 0372','3731 136303 90318','01/05/1936'),('Marsden Johnston','ornare@nullaCras.edu','Mazy','16620430 1391','3402 271275 29020','12/11/1964'),('Joshua Black','ac.sem.ut@Namnulla.org','Baddeck','16650211 8836','3728 364887 81987','08/03/1954'),('Clinton Mendoza','Nunc@duiaugueeu.edu','Colombes','16350928 6153','346807230022742','08/01/2013'),('Ali Mcdowell','dis.parturient.montes@interdumenim.ca','Itabuna','16920804 9057','343910802965638','04/18/1965'),('Kuame Roberson','dictum@Quisque.org','BertrŽe','16030105 7436','370287762707292','02/01/1936'),('Garrison Chase','aliquam.eros@ultricesposuere.org','Nogales','16791016 2614','3467 278572 20017','09/06/1947');
INSERT INTO CUSTOMER( FULLNAME , EMAILID , CITY , SSN , CREDITCARD , DATEOFBIRTH ) VALUES('Quinlan Cain','pellentesque.a@fringilla.org','Lyubertsy','16790419 4557','377774057842762','01/17/1951'),('Kareem Garner','Duis.risus.odio@diamSeddiam.edu','Wellington','16100717 4962','373111391450180','11/25/1995'),('Bernard Maldonado','mi.lorem.vehicula@semperetlacinia.ca','Chiusa/Klausen','16140412 0394','341771444624047','11/05/1955'),('William Benton','sapien.Nunc.pulvinar@tinciduntnibh.ca','Ñiquén','16290903 5491','348858897754687','12/05/1981'),('Linus Hunt','eros.Nam@feugiatLoremipsum.co.uk','Tailles','16950624 9367','3463 921356 07590','08/05/2009'),('Ronan Barron','turpis.Aliquam.adipiscing@faucibus.ca','Ruza','16941129 2080','379600376776852','04/07/1955'),('Bert Harmon','commodo.auctor.velit@egetmagnaSuspendisse.ca','Thurso','16730325 1354','3435 377967 18242','12/14/1976'),('Ivor Estes','magna@eliterat.net','Rhayader','16420825 6455','379773057604709','10/18/1996'),('Silas Blackburn','a.facilisis@tempor.net','Eghezee','16910505 0315','343218708462910','01/15/1993'),('Abel Flores','nisi@taciti.edu','Istra','16330721 7434','3490 962574 82115','03/17/1934');
INSERT INTO CUSTOMER( FULLNAME , EMAILID , CITY , SSN , CREDITCARD , DATEOFBIRTH ) VALUES('Stuart Valentine','imperdiet.ullamcorper.Duis@nonbibendum.ca','Bunbury','16681208 6061','349810970409555','08/25/1939'),('Walker Robertson','vestibulum.neque@non.net','Frauenkirchen','16640905 0637','349538667249428','06/24/1999'),('Brennan Chen','leo.elementum@mi.co.uk','Reno','16750703 4598','374108053120233','09/17/1981'),('William Blanchard','tellus.lorem@commodotincidunt.co.uk','Sossano','16711005 5774','3472 481853 80067','01/08/1997'),('Felix Fox','Mauris.nulla@non.ca','Schwaz','16320405 2041','340760277005912','06/15/1951'),('Paki Porter','cursus.diam@estmollisnon.com','Gonda','16240712 3633','345334346075754','06/15/2007'),('Abdul Oconnor','Nulla.eu.neque@ametconsectetueradipiscing.edu','Comblain-la-Tour','16380126 3439','3421 409276 34551','08/22/1981'),('Jared Bentley','vitae.mauris@ultricies.com','Thorold','16510515 1152','375714570055262','11/02/1938'),('Burton Powell','vulputate@sem.net','Herne','16410718 8882','3405 347319 67813','12/24/1940'),('Howard Arnold','facilisis.eget@estNuncullamcorper.net','Hubli','16540225 7124','348592711112760','04/22/2018');
INSERT INTO CUSTOMER( FULLNAME , EMAILID , CITY , SSN , CREDITCARD , DATEOFBIRTH ) VALUES('Ivor Ellison','ullamcorper.eu.euismod@hendrerita.net','Punta Arenas','16930111 5300','3759 115951 55248','05/27/2007'),('Hedley Hernandez','massa.Suspendisse.eleifend@velitegestaslacinia.net','Nancagua','16550518 0660','349742987165757','07/15/1996'),('Elmo Raymond','amet.ante.Vivamus@ipsum.net','Dunbar','16530715 0606','3427 539296 56149','11/29/1955'),('Bruno Barr','Aliquam@loremipsum.ca','Bonnyville','16900906 5922','3792 330616 16207','10/12/1948'),('Harrison Russo','et@auctornuncnulla.ca','Segovia','16510707 8395','372183671882961','05/15/1964'),('Gage Holman','per.inceptos@ridiculus.ca','Freirina','16190612 6477','3753 866059 48090','08/14/1949'),('Donovan Hoffman','nunc.sed@tristique.com','Ried im Innkreis','16240728 5796','3792 023972 42095','05/20/1951'),('Acton Sharp','vulputate@Mauris.com','Wekweti','16911125 1378','373057444117807','04/01/1950'),('Simon Wilson','facilisis.magna@sit.ca','Fermont','16621117 2009','347944246285358','08/28/1989'),('Ian Tanner','vulputate@montesnascetur.ca','Villamassargia','16630609 5693','341423980086880','01/13/1975');
INSERT INTO CUSTOMER( FULLNAME , EMAILID , CITY , SSN , CREDITCARD , DATEOFBIRTH ) VALUES('Ferdinand Ellis','semper.erat.in@sed.ca','Monteu Roero','16570306 6596','343347972000724','04/16/1937'),('Elton Maxwell','lectus.convallis@a.ca','Modena','16180426 5385','342013420236457','07/23/1986'),('Wayne Park','elementum@ipsumleoelementum.co.uk','Beaumont','16360128 3876','3703 190100 91334','09/07/1955'),('Murphy Ware','dolor.vitae.dolor@lorem.net','New Plymouth','16460826 7896','343395007513385','01/03/1939'),('Tanek Hale','a.odio.semper@parturientmontes.net','Subbiano','16350307 5636','3401 088143 09795','12/09/2010'),('Orson Key','at@Donecfelis.com','Muno','16010821 2119','372664577143632','08/17/1972'),('Reed Mcmahon','ultricies.sem.magna@Suspendisse.ca','Verzegnis','16740613 2899','375962528415829','12/07/1940'),('Kaseem Chapman','nisl.arcu.iaculis@ligulaelitpretium.org','El Tambo','16920208 4860','346443262856086','04/22/1965'),('Reese Sandoval','tempor.lorem@ligulaDonecluctus.ca','Little Rock','16990223 2710','376743634958160','03/17/2019'),('Honorato Spears','felis.ullamcorper@nequeInornare.net','Alès','16720627 2606','3425 514265 44499','06/06/2002');
INSERT INTO CUSTOMER( FULLNAME , EMAILID , CITY , SSN , CREDITCARD , DATEOFBIRTH ) VALUES('Peter Alston','nibh@nonmassanon.ca','Saint-Honor ','16341019 8430','3457 740383 93256','10/04/1954'),('Cyrus Warner','natoque@vel.net','Albacete','16601106 2442','3430 124453 64236','06/25/1964'),('Kieran Simpson','sit.amet.risus@erat.co.uk','Carpignano Salentino','16221127 9720','3733 403944 52816','08/06/1990'),('Beau Knight','sodales@ipsumporta.com','Negrete','16180311 0376','347582397314633','10/18/2010'),('Benedict Stuart','Nam.nulla@amet.com','Gougnies','16310304 9825','3725 026048 75380','01/15/1933'),('Gage Powell','nibh@dictumeueleifend.edu','Wekweti','16690802 3804','3730 806106 06932','06/02/1989'),('Geoffrey Fowler','Praesent.eu.dui@laoreetposuereenim.org','Enschede','16360925 6445','3720 048414 95528','09/08/1984'),('Hamish Turner','sed@FuscefeugiatLorem.net','Pordenone','16450402 5919','3797 534918 02929','07/06/2018'),('Lucius Graves','tincidunt@et.edu','Smoky Lake','16220118 9988','3772 260480 10959','09/27/1994'),('Kennan Padilla','massa@odioPhasellus.edu','Blaenau Ffestiniog','16540203 2402','3476 137143 13477','01/15/1967');

SELECT COUNT (*) FROM "FINANCE"."STAGE"."CUSTOMER";
SELECT * FROM "FINANCE"."STAGE"."CUSTOMER";

--Step 2 - User Creation To Test Masking Functionality
Create USER PII_USER Password=PII_User@21 DEFAULT_ROLE = Masking_Admin MUST_CHANGE_PASSWORD = FALSE;

Create Role Masking_Admin;

Grant Role Masking_Admin To User PII_USER;

Grant All Privileges On DATABASE Finance To Role Masking_Admin;
Grant All Privileges On DATABASE Finance To Role SYSADMIN;
Grant All Privileges On DATABASE Finance To Role ACCOUNTADMIN;

Grant All Privileges On Warehouse compute_wh To Role Masking_Admin;

Grant All On All Schemas In DATABASE Finance To Role MASKING_ADMIN;
Grant All On All Schemas In DATABASE Finance To Role SYSADMIN;

Grant All On All TABLES In DATABASE Finance To Role SYSADMIN;

Grant Apply Masking Policy On Account To Role Masking_Admin;

Grant Create Masking Policy On Schema STAGE To Role Masking_Admin;

--Step 3 - Log In Using PII_USER To Run Below Query/ Masking Code
--Create a new policy
Create Or Replace Masking Policy STAGE.SSN_Policy As (SSN  string) Returns string ->
Case When current_role() in ('MASKING_ADMIN') Then
        SSN
    ELSE
        '**Masked SSN**'
END;

---Associate it
Alter Table Customer Modify Column SSN Set Masking Policy Stage.SSN_Policy;

SELECT * FROM STAGE.CUSTOMER;

Create Or Replace Masking Policy STAGE.Email_Policy As (EMAIL  string) Returns string ->
Case When current_role() in ('MASKING_ADMIN') Then EMAIL
     WHEN current_role() in ('ACCOUNTADMIN')  Then regexp_replace(EMAIL,'.+\@','*****@')
     Else  '**Masked Email**'
END;

Alter Table Customer Modify Column EMAILID Set Masking Policy Stage.Email_Policy;

SELECT * FROM STAGE.CUSTOMER;
