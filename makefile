USER = hypolite
DBNAME = elections022012
HOST = localhost
PORT = 5435
PASSWORD= TEST

TARGET =$(DBNAME)@$(HOST):$(PORT)

# Usual path for pg_config :
# PG_CONFIG = pg_config
# Or specific :
 PG_CONFIG = /usr/local/pgsql/bin/pg_config
SHAREDIR = $(shell $(PG_CONFIG) --sharedir)

all:  bin/Anelosimus.Eximius
clean: 
	rm bin/Anelosimus.Eximius
	rm $(SHAREDIR)/extension/url.*

extensions: $(SHAREDIR)/extension/url.sql  $(SHAREDIR)/extension/url.so
		
$(SHAREDIR)/extension/url.so:	c/url.so
	cp c/url.so $(SHAREDIR)/extension/url.so
	chown postgres.postgres $(SHAREDIR)/extension/url.so
$(SHAREDIR)/extension/url.sql:	sql/url.sql
	sed "s:_OBJWD_:"$(SHAREDIR)"/extension:g" sql/url.sql > $(SHAREDIR)/extension/url.sql
	chown postgres.postgres $(SHAREDIR)/extension/url.sql
c/url.so: c/url.c
	echo $(SHAREDIR)
	  cd c; make ; cd .. 
CreateTables: $(SHAREDIR)/extension/url.sql sql/url.sql sql/CreateTables.sql 
	psql -U$(USER) -h$(HOST) -p$(PORT) -d$(DBNAME) -W -f $(SHAREDIR)/extension/url.sql
	psql -U$(USER) -h$(HOST) -p$(PORT) -d$(DBNAME) -W -f sql/CreateTables.sql 
bin: 
	mkdir bin
bin/Anelosimus.Eximius : bin ecpg/Anelosimus.Eximius.pgc 
	cd ecpg
	ecpg -t -I/usr/include/postgresql -I/usr/include/curl ecpg/Anelosimus.Eximius.pgc
	gcc -g -D_TARGET_=\"$(TARGET)\" -D_USER_=\"$(USER)\" -D_PASSWORD_=\"$(PASSWORD)\" -o bin/Anelosimus.Eximius -I /usr/include/postgresql/ ecpg/Anelosimus.Eximius.c -lecpg -lpq -lcurl

