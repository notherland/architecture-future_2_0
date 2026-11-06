# Задание 1. Целевая архитектура (C4 Container) — через 1 год

## Диаграмма контейнеров (C4)

```mermaid
C4Container
    title Future 2.0 — целевая архитектура (контейнеры)

    Person(analyst, "Бизнес-пользователь", "Отчёты в рамках доступа")
    Person(doctor, "Врач / оператор клиники", "Клинические сценарии")
    Person(fin_user, "Сотрудник финтеха", "Счета, кредиты")

    System_Boundary(portal, "Домен Analytics / Self-Service") {
        Container(portal_ui, "Портал самообслуживания", "Web", "Конструктор отчётов, RBAC")
        Container(bi, "BI / Semantic Layer", "Power BI / Cube", "Метрики KPI без медкарт")
        Container(lakehouse, "Аналитическое хранилище", "Cloud Lakehouse", "Витрины доменов")
    }

    System_Boundary(clinic, "Домен Clinic") {
        Container(ehr, "Клиническая система", "Cloud App", "Карты, исследования (не в витрину)")
        Container(clinic_api, "Clinic API", "API", "Операционные данные клиники")
    }

    System_Boundary(fintech, "Домен Fintech") {
        Container(fin_svc, "Финтех-сервисы", "Go/Java", "Счета, кредиты, платежи")
        Container(fin_db, "Fintech OLTP", "Cloud DB", "Финансовые транзакции")
    }

    System_Boundary(ai, "Домен AI") {
        Container(ai_svc, "ИИ-сервисы", "Python", "Диагностика / рекомендации")
        Container(ai_feat, "Feature Store", "Cloud", "Признаки без PII в витрину")
    }

    System_Boundary(platform, "Домен Platform / Integration") {
        Container(bus, "Event / Integration Bus", "Kafka / API Gateway", "Замена ESB")
        Container(mdm, "MDM / Client 360", "Service", "Единый клиент для KPI")
        Container(iam, "IAM / Audit", "IdP", "Доступ и аудит")
    }

    System_Ext(partners, "Партнёры", "Фарма, электроника")
    System_Ext(legacy, "Legacy DWH (временный)", "SQL Server 2008", "Read-only / миграция")

    Rel(analyst, portal_ui, "Строит отчёты")
    Rel(portal_ui, bi, "Запросы метрик")
    Rel(bi, lakehouse, "Читает витрины")
    Rel(doctor, ehr, "Работает с картами")
    Rel(fin_user, fin_svc, "Операции")
    Rel(ehr, ai_svc, "Медданные для ИИ (закрытый контур)")
    Rel(clinic_api, bus, "События: визиты, счета клиники")
    Rel(fin_svc, bus, "События: платежи, кредиты")
    Rel(ai_svc, bus, "Агрегированные события качества")
    Rel(bus, lakehouse, "CDC / события в витрины доменов")
    Rel(bus, mdm, "Идентичности клиентов")
    Rel(mdm, lakehouse, "Справочники клиента")
    Rel(partners, bus, "Интеграция новых бизнесов")
    Rel(legacy, lakehouse, "Миграция / исторические срезы")
    Rel(iam, portal_ui, "RBAC")
    Rel(iam, fin_svc, "RBAC")
    Rel(iam, ehr, "RBAC")
```

## Как Kafka + API Gateway закрывают функции ESB

Контейнер на диаграмме тот же (`Event / Integration Bus`). Внутри него функции Apache Camel разносятся так, без отдельного «ESB-монолита» и без переноса бизнес-логики в шину:

| Функция ESB | Чем закрывается |
|-------------|-----------------|
| Маршрутизация, синхронные API, auth, квоты | API Gateway |
| Асинхронные интеграции, pub/sub, CDC | Kafka |
| ФЛК | Контракт события (Schema Registry) + проверки в сервисе-источнике |
| Потоковые трансформации | Kafka Streams / Flink (нормализация, обогащение, отсечение медкарт) |
| Пакетные трансформации | Отдельные batch-джобы в витрины Lakehouse (не ночные маршруты в DWH) |
| Надёжность | Outbox, retry/DLQ, идемпотентные потребители, replay топика |
| Бизнес-логика и оркестрация продукта | Остаётся в доменах (Fintech, Clinic, AI), не в шине |

## Как архитектура поддерживает бизнес-сценарии

| Сценарий | Как поддерживается |
|----------|-------------------|
| Быстрая отчётность | Портал + semantic layer + витрины доменов в lakehouse; без тяжёлых ad-hoc трансформаций в монолитном DWH |
| Независимое развитие финтеха | Отдельный домен Fintech (сервисы + OLTP), публикация событий в шину, свои витрины |
| Независимое развитие ИИ | Закрытый контур Clinic↔AI; в аналитику только агрегаты/качество, не медкарты |
| Масштабирование новых бизнесов | Partners → Integration Bus → витрины; логика не пишется в старый DWH |
| Комплаенс | IAM/Audit + исключение медкарт/исследований из витрины |

См. также файл `c4_container_diagram.png` (упрощённая схема).
