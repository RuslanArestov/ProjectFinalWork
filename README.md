## 1. Создание облачной инфраструктуры

На начальном этапе я создал в консоли Yandex Cloud сервисный аккаунт backend-sa с необходимыми ролями для создания бакета.

![Alt text](https://github.com/RuslanArestov/ProjectFinalWork/blob/main/images/Diplom/backend-sa.png) </br>

Далее в директории Backend написал создание сервисного аккаунта infra-sa для развертывания основной инфраструктуры, бакета для удаленного хранения state файлов Terraform и авторизованного ключа для сервисного аккаунта.

![Alt text](https://github.com/RuslanArestov/ProjectFinalWork/blob/main/images/Diplom/states.png) </br>

В директории Infrastructure описана вся инфраструктура. Написал создание VPC, master, worker нод для K8s, ALB для доступа к приложениям в K8s-кластере, Yandex Container Registry с автоматическим сканированием образов. Ноды кластера K8s находятся в приватной сети. Доступ к ним организован через бастион-хост, который также обеспечивает выход кластера в интернет.

![Alt text](https://github.com/RuslanArestov/ProjectFinalWork/blob/main/images/Diplom/infrastructure.png) </br>

## 2. Развертывание отказоустойчивого кластера Kubernetes

Развернул отказоустойчивый кластер Kubernetes с тремя мастер-нодами с помощью роли Kubespray. Доступ к кластеру настроил через SSH-туннель с локальной машины через Бастион-хост.

## 3. Подготовка тестового приложения

Создал тестовое приложение на основе образа nginx и разместил его в репозитории https://github.com/RuslanArestov/Nginx-app. Приложение автоматически собирается и отправляется в Yandex Container Registry в процессе развертывания инфраструктуры.

## 4. Настройка деплоя и мониторинга

Для развертывания системы мониторинга использовал пакет kube-prometheus. Внес корректировки в конфигурацию Grafana (увеличил лимиты ресурсов) для обеспечения стабильной работы.

![Alt text](https://github.com/RuslanArestov/ProjectFinalWork/blob/main/images/Diplom/dashboard.png) </br>

![Alt text](https://github.com/RuslanArestov/ProjectFinalWork/blob/main/images/Diplom/dashboard2.png) </br>

Развернул nginx-приложение с помощью манифестов, используя образы из Yandex Container Registry.

Установил Atlantis с помощью Helm-чарта. Создал StorageClass и настроил проброс в контейнер Atlantis секретов и файла .terraformrc.

![Alt text](https://github.com/RuslanArestov/ProjectFinalWork/blob/main/images/Diplom/atlantis.png) </br>

Настроил вебхуки в репозитории проекта для автоматизации workflow.
![Alt text](https://github.com/RuslanArestov/ProjectFinalWork/blob/main/images/Diplom/webhooks.png) </br>

Установил Nginx Ingress Controller и проверил работоспособность Atlantis, а также доступ к nginx-приложению по HTTP.

![Alt text](https://github.com/RuslanArestov/ProjectFinalWork/blob/main/images/Diplom/atlantis_jobs.png) </br>

![Alt text](https://github.com/RuslanArestov/ProjectFinalWork/blob/main/images/Diplom/atlantis_plan.png) </br>

![Alt text](https://github.com/RuslanArestov/ProjectFinalWork/blob/main/images/Diplom/nginx-app.png) </br>


## 5. Настройка CI/CD с Github Actions

![Alt text](https://github.com/RuslanArestov/ProjectFinalWork/blob/main/images/Diplom/github_secrets.png) </br>

Настроил автоматическую сборку образов и их отправку в Yandex Container Registry с помощью Github Actions.

![Alt text](https://github.com/RuslanArestov/ProjectFinalWork/blob/main/images/Diplom/YCR_docker_images_tag.png) </br>

Реализовал автоматический деплой приложений из Yandex Container Registry в Kubernetes при внесении изменений в код репозитория приложения.

![Alt text](https://github.com/RuslanArestov/ProjectFinalWork/blob/main/images/Diplom/deploy_tag_v1.0.0.png) </br>
