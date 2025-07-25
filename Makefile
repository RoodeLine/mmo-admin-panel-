APP_NAME = mmo-admin-panel
DB_NAME = mmo_admin
DB_USER = mmo_admin_user
DB_PASS = mmo_secure_pass
DB_HOST = localhost
DB_PORT = 5432
PG_ADMIN = postgres
NEW_PG_PASS = mySuperSecureNewPassword123
TEST_DATA_FILE = src/main/resources/db/insert_test_data.sql


.PHONY: all check-deps install-deps install build run db-create db_drop create-user clean test change-password reset-postgres-password

all: db_drop check-deps reset-postgres-password create-user db-create insert-test-data install build run

check-deps: install-deps
	@java_version=$$(java -version 2>&1 | awk -F[\".] '/version/ {print $$2}') && \
	[ $$java_version -ge 17 ] || (echo "❌ Требуется Java 17+. Найдено: $$java_version" && exit 1)
	@echo "✅ Все зависимости установлены."

install-deps:
	@echo ">>> Проверка и установка зависимостей..."
	@if ! which java > /dev/null; then \
		echo "⚠️ Java не найден. Устанавливаю OpenJDK 17..."; \
		sudo apt update && sudo apt install -y openjdk-17-jdk; \
	fi

	@if ! which mvn > /dev/null; then \
		echo "⚠️ Maven не найден. Устанавливаю Maven..."; \
		sudo apt update && sudo apt install -y maven; \
	fi

	@if ! which psql > /dev/null; then \
		echo "⚠️ psql не найден. Устанавливаю PostgreSQL client..."; \
		sudo apt update && sudo apt install -y postgresql-client; \
	fi

install:
	@echo ">>> Установка зависимостей Maven..."
	mvn clean install -DskipTests

build:
	@echo ">>> Сборка проекта..."
	mvn package -DskipTests

run:
	@echo ">>> Запуск приложения..."
	mvn spring-boot:run

test:
	mvn test

reset-postgres-password:
	@echo ">>> Смена пароля пользователя 'postgres'..."
	@echo "ALTER USER postgres WITH PASSWORD '$(NEW_PG_PASS)';" | sudo -u postgres psql >/dev/null 2>&1 && \
	echo "✅ Пароль успешно изменён." || echo "❌ Не удалось изменить пароль."

create-user:
	@echo ">>> Создание пользователя '${DB_USER}'..."
	@PGPASSWORD=$(NEW_PG_PASS) psql -h $(DB_HOST) -U $(PG_ADMIN) -tc "SELECT 1 FROM pg_roles WHERE rolname='$(DB_USER)'" | grep -q 1 || \
	PGPASSWORD=$(NEW_PG_PASS) psql -h $(DB_HOST) -U $(PG_ADMIN) -c "CREATE USER $(DB_USER) WITH PASSWORD '$(DB_PASS)';"
	@PGPASSWORD=$(NEW_PG_PASS) psql -h $(DB_HOST) -U $(PG_ADMIN) -c "ALTER USER $(DB_USER) CREATEDB;"

db-create:
	@echo ">>> Создание базы данных '${DB_NAME}'..."
	@PGPASSWORD=$(NEW_PG_PASS) psql -h $(DB_HOST) -U $(PG_ADMIN) -tc "SELECT 1 FROM pg_database WHERE datname = '$(DB_NAME)'" | grep -q 1 || \
	PGPASSWORD=$(NEW_PG_PASS) createdb -h $(DB_HOST) -U $(PG_ADMIN) -O $(DB_USER) $(DB_NAME)

	@echo ">>> Применение Liquibase миграций..."
	mvn liquibase:update \
	    -Dliquibase.url=jdbc:postgresql://$(DB_HOST):$(DB_PORT)/$(DB_NAME) \
	    -Dliquibase.username=$(DB_USER) \
	    -Dliquibase.password=$(DB_PASS) \
	    -Dliquibase.changeLogFile=src/main/resources/db/changelog/db.changelog-master.xml

db_drop:
	@echo ">>> Завершаю все подключения к базе '${DB_NAME}'..."
	@PGPASSWORD=$(NEW_PG_PASS) psql -h $(DB_HOST) -U $(PG_ADMIN) -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$(DB_NAME)';"
	@echo ">>> Удаление базы '${DB_NAME}'..."
	@PGPASSWORD=$(NEW_PG_PASS) dropdb -h $(DB_HOST) -U $(PG_ADMIN) --if-exists $(DB_NAME)


insert-test-data:
	@echo ">>> Вставка экспериментальных данных из '$(TEST_DATA_FILE)'..."
	@PGPASSWORD=$(DB_PASS) psql -h $(DB_HOST) -U $(DB_USER) -d $(DB_NAME) -f $(TEST_DATA_FILE)

clean:
	mvn clean
