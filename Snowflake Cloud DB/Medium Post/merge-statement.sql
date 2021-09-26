----Account Setup----
Use Role Role_Name;
Use Warehouse Warehouse_Name;
Use DataBase DataBase_Name;
Use Schema Schema_Name;

--------------Source Table Structure--------------
Create OR Replace Table DataBase_Name.Schema_Name.CUSTOMER (
CUSTOMER_ID	INTEGER NOT NULL,
FullNAME	VARCHAR(50),
EMAIL 		VARCHAR(30),
ADDRESS		VARCHAR(100),
	PRIMARY KEY(CUSTOMER_ID)
);

/*Sample Data Inserts*/
INSERT INTO DEMO_DB.PUBLIC.CUSTOMER VALUES(880,'Steven King', 'Steven.K@biz.com','2017 Shinjuku-ku, Tokyo, JP, 5670');
INSERT INTO DEMO_DB.PUBLIC.CUSTOMER VALUES(881,'Neena Kochhar', 'Neena.K@biz.com','2014 Jabberwocky Rd, Texas, US, 26192');
INSERT INTO DEMO_DB.PUBLIC.CUSTOMER VALUES(882,'Lex De Haan', 'LexDe.H@biz.com','2011 Interiors Blvd, California, US, 99236');

--Data Updates For Testing
UPDATE DEMO_DB.PUBLIC.CUSTOMER SET ADDRESS = '1010 Chester Rd, Manchester, UK, 0962' Where CUSTOMER_ID = 882;

SELECT * FROM DEMO_DB.PUBLIC.CUSTOMER;

--------------Target Table Structure--------------
Create OR Replace Table DataBase_Name.Schema_Name.DIM_CUSTOMER (
CUSTOMER_KEY    INTEGER NOT NULL IDENTITY(1,1),  --Surrogate Key
CUSTOMER_ID		INTEGER,              	         --Natural Key
FULLNAME		VARCHAR(50),
EMAIL           VARCHAR(30),
ADDRESS	        VARCHAR(100),
ACTIVE_FLAG     VARCHAR(1),           			--Active Flag 
START_DATE      DATE,                 			--Effictive Start Date
END_DATE        DATE,                 			--Effictive End Date
	PRIMARY KEY(CUSTOMER_KEY)
);

--------------Merge Statement Functionality--------------
Merge Into DataBase_Name.Schema_Name.DIM_CUSTOMER Tgt Using (
	Select Src.CUSTOMER_ID As JOIN_KEY, Src.* From DataBase_Name.Schema_Name.CUSTOMER Src
	Union ALL
	Select NULL, Src.* From DataBase_Name.Schema_Name.CUSTOMER Src
	Join DataBase_Name.Schema_Name.DIM_CUSTOMER Tgt 
		ON Tgt.customer_ID = Src.customer_ID 
	Where (
			    (Tgt.EMAIL <> Src.EMAIL OR Tgt.ADDRESS <> Src.ADDRESS)
          And Tgt.END_DATE IS NULL
	      )
) DataSet
	ON DataSet.JOIN_KEY = Tgt.CUSTOMER_ID

WHEN MATCHED
	AND (DataSet.EMAIL <> Tgt.EMAIL OR DataSet.ADDRESS <> Tgt.ADDRESS)
THEN UPDATE
	SET END_DATE = CURRENT_DATE(), ACTIVE_FLAG = 'N'

WHEN NOT MATCHED THEN INSERT ( 
	CUSTOMER_ID,
	FULLNAME,
	EMAIL,
	ADDRESS,
	ACTIVE_FLAG,
	START_DATE
)
Values (
	DATASET.CUSTOMER_ID,
	DATASET.FULLNAME,
	DATASET.EMAIL,
	DATASET.ADDRESS,
	'Y',
	CURRENT_DATE()
);

SELECT * FROM DATABASE_NAME.SCHEMA_NAME.DIM_CUSTOMER ORDER BY 1 ASC;
