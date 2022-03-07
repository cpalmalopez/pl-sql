/*
*   Función que permite validar si existe una persona en la tabla PER_PERSONAS, y
*   según eso, realizar determinadas acciones.
*
*   Acciones:
*   - Si existe el RUT en PER_PERSONAS, hace un INSERT en la tabla COLABORADOR.
*   - Si no existe el RUT, hace un INSERT en PER_PERSONAS, PER_DETPER, PER_IDENTIFICADOR y COLABORADOR.
*   - Si existe el SPERSON en COLABORADOR, hace un UPDATE a la fila con ese SPERSON.
*/

CREATE OR REPLACE FUNCTION F_COLABORADOR (
    I_RUT IN VARCHAR2,
    I_DV IN VARCHAR2, 
    I_PRIMER_NOMBRE IN VARCHAR2,
    I_APELLIDO_P IN VARCHAR2,
    I_APELLIDO_M IN VARCHAR2,
    I_SEXO IN NUMBER,
    I_FECHA_NACIMIENTO IN DATE,
    I_ESTADO IN NUMBER,
    I_FECHA_INGRESO IN DATE,
    I_FECHA_SALIDA IN DATE
)
RETURN NUMBER AS 

CONTADOR NUMBER;
EXISTE_COLAB NUMBER;
SPERSON_PERSONA NUMBER;
SEQ_SPERSON NUMBER;
SEQ_NMOVIMI NUMBER;
BEGIN  
    SELECT count(*) INTO CONTADOR 
    FROM PER_PERSONAS
	WHERE NNUMIDE = I_RUT;
    
        
    -- RESULTADOS DE RETURNS
    -- 1 = ACTUALIZA COLABORADOR
    -- 2 = CREA COLABORADOR
    -- 3 = CREA EN LAS 4 TABLAS
    
    IF (CONTADOR = 1) THEN
    
        SELECT SPERSON INTO SPERSON_PERSONA FROM PER_PERSONAS
        WHERE NNUMIDE = I_RUT;
        
        SELECT count(*) INTO EXISTE_COLAB
        FROM COLABORADOR
        WHERE SPERSON = SPERSON_PERSONA;
        
        IF (EXISTE_COLAB = 1) THEN
            
            -- ACTUALIZO
            UPDATE COLABORADOR
            SET FINGRESO = I_FECHA_INGRESO, FSALIDA = I_FECHA_SALIDA, ESTADO = I_ESTADO
            WHERE SPERSON = SPERSON_PERSONA;
            
            RETURN 1;
        ELSE
            -- LO CREO
            SELECT S_NMOVIMI_COLAB.NEXTVAL
            INTO SEQ_NMOVIMI
            FROM DUAL;
        
            INSERT INTO COLABORADOR (SPERSON, NMOVIMI, FINGRESO, FSALIDA, ESTADO)
            VALUES (SPERSON_PERSONA, SEQ_NMOVIMI, I_FECHA_INGRESO, I_FECHA_SALIDA, I_ESTADO);
            
            COMMIT;
            
            RETURN 2;
        END IF;        
    ELSE 
		SELECT AXIS_DESA.SPERSON.NEXTVAL
        INTO SEQ_SPERSON
        FROM DUAL;

		SELECT S_NMOVIMI_COLAB.NEXTVAL
		INTO SEQ_NMOVIMI
		FROM DUAL;

        -- CREAR EN PER_PERSONAS
        INSERT INTO PER_PERSONAS (
            SPERSON, -- NOT NULL
            NNUMIDE, -- NOT NULL
            NORDIDE, -- NOT NULL
            CTIPIDE, -- NOT NULL
            CSEXPER, 
            FNACIMI, 
            CESTPER, -- NOT NULL
            FJUBILA,
            CUSUARI, -- NOT NULL
            FMOVIMI, -- NOT NULL
            CMUTUALISTA,
            FDEFUNC,
            SNIP, 
            SWPUBLI, -- NOT NULL
            CTIPPER, -- NOT NULL
            TDIGITOIDE, 
            CPREAVISO,
            CAGENTE,
            CUSUALT,
            FALTA
        )
        VALUES (
            SEQ_SPERSON, -- SPERSON
            I_RUT, -- NNUMIDE
            1,  -- NORDIDE
            41,  -- CTIPIDE
            I_SEXO, -- CSEXPER
            I_FECHA_NACIMIENTO, -- FNACIMI 
            0, -- CESTPER
            NULL, -- FJUBILA
            'AXIS_REALE', -- CUSUARI
            SYSDATE, -- FMOVIMI
            NULL, -- CMUTIALISTA
            NULL, -- FDEFUNC
            NULL, -- SNIP
            1, -- SWPUBLI
            1, -- CTIPPER
            I_DV, -- TDIGITOIDE
            NULL, -- CPREAVISO
            NULL, -- CAGENTE
            NULL, -- CUSUALT
            NULL -- FALTA
        );
        
        -- CREAR DATA PER_DETPER
        INSERT INTO PER_DETPER (
            SPERSON, -- NOT NULL
            CAGENTE, -- NOT NULL
            CIDIOMA, 
            TAPELLI1, 
            TAPELLI2, 
            TNOMBRE,
            TSIGLAS,
            CPROFES,
            TBUSCAR, 
            CESTCIV,
            CPAIS, 
            CUSUARI, -- NOT NULL
            FMOVIMI, -- NOT NULL
            TNOMBRE1, 
            TNOMBRE2,
            COCUPACION,
            NOMFANTASIA, 
            IALERTA
        )
        VALUES (
            SEQ_SPERSON, -- SPERSON
            1000000001, -- CAGENTE
            NULL, -- CIDIOMA
            I_APELLIDO_P, -- TAPELLI1
            I_APELLIDO_M, -- TAPELLI2
            I_PRIMER_NOMBRE, -- TNOMBRE
            NULL, -- TSIGLAS
            NULL, -- CPROFES
            NULL, -- TBUSCAR
            NULL, -- CESTCIV
            NULL, -- CPAIS
            'AXIS_REALE', -- CUSUARI
            SYSDATE,  -- FMOVIMI
            I_PRIMER_NOMBRE, -- TNOMBRE1
            NULL, -- TNOMBRE2
            NULL, -- OCUPACION
            NULL, -- NOMFANTASIA
            NULL -- IALERTA
        );

        -- CREAR DATA PER_IDENTIFICADOR
        INSERT INTO PER_IDENTIFICADOR (
            SPERSON, -- NOT NULL
            CAGENTE, -- NOT NULL
            CTIPIDE, -- NOT NULL
            NNUMIDE, -- NOT NULL
            SWIDEPRI, 
            FEMISIO, 
            CPAISEXP
        )
        VALUES (
            SEQ_SPERSON, -- SPERSON
            1000000001, -- CAGENTE
            41, -- CTIPIDE
            I_RUT, -- NNUMIDE
            NULL, -- SWIDEPRI
            NULL, -- FEMISIO
            NULL -- CPAISEXP
        );
        
        -- CREAR DATA COLABORADOR
        INSERT INTO COLABORADOR (SPERSON, NMOVIMI, FINGRESO, FSALIDA, ESTADO)
        VALUES (SEQ_SPERSON, SEQ_NMOVIMI, I_FECHA_INGRESO, I_FECHA_SALIDA, I_ESTADO);
        
        COMMIT;
        
        RETURN 3;
    END IF;
    
    EXCEPTION
            WHEN OTHERS THEN
                --RETURN SQLERRM;
                RETURN 0;
    RETURN CONTADOR;
END F_COLABORADOR;