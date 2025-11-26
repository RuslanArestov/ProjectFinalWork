1. Создание облачной инфраструктуры

Сначала я создал в консоли Yandex Cloud сервисный аккаунт backend-sa с необходимыми ролями для поднятия бакета.
![Alt text](https://github.com/RuslanArestov/ProjectFinalWork/blob/main/images/backend-sa.png) </br>

Далее в директории Backend написал создание сервисного аккаунта infra-sa, который будет поднимать основную инфраструктуру, и бакета для удаленного хранения state файлов.

![Alt text](https://github.com/RuslanArestov/ProjectFinalWork/blob/main/images/states.png) </br>

А также создание авторизованного ключа для сервисного аккаунта.

В директории Infrastructure - вся инфраструктура - написал создание VPC, master, worker ноды для K8s, ALB для доступа к приложениях, расположенных в кластере K8s, Yandex Container Registry с автоматическим сканированием образов. Ноды кластера K8s находятся в приватной сети. Доступ к ним можно получить через Бастион-хост. Через него же кластер выходит в Интернет.

![Alt text](https://github.com/RuslanArestov/ProjectFinalWork/blob/main/images/infrastructure.png) </br>

2. Создал кластер отказоустойчивый K8s с 3 мастер-нодами с помощью роли Kubespray.

Доступ к кластеру настроил через SSH-туннель с локальной машины через Бастион-хост

3. Создал тестовое приложение на основе nginx образа и разместил его в репозитории https://github.com/RuslanArestov/Nginx-app.
Приложение при поднятии инфраструктуры собирается и пушится в Yandex Container Registry.

4. Для деплоя мониторинга использовал пакет kube-prometheus. Внес небольшие изменения (увеличил лимиты ресурсов) в конфигурационный файл grafana для устойчивой работы.

![Alt text](https://github.com/RuslanArestov/ProjectFinalWork/blob/main/images/dashboard.png) </br>

![Alt text](https://github.com/RuslanArestov/ProjectFinalWork/blob/main/images/dashboard2.png) </br>

Задеплоил nginx-приложение с помощью манифестов из Yandex Container Registry

Задеплоил Atlantis с помощью helm манифеста. Создал storageclass. Пробросил в контейнер Atlantis секреты, файл .terrafromrc.

![Alt text](https://github.com/RuslanArestov/ProjectFinalWork/blob/main/images/atlantis.png) </br>

Настроил вебхуки в репозитории проекта
![Alt text](https://github.com/RuslanArestov/ProjectFinalWork/blob/main/images/webhooks.png) </br>

Установил Nginx Ingress Controller
Проверил работу Atlantis и доступ к nginx-приложениею по http. 

![Alt text](https://github.com/RuslanArestov/ProjectFinalWork/blob/main/images/atlantis_jobs.png) </br>

![Alt text](https://github.com/RuslanArestov/ProjectFinalWork/blob/main/images/atlantis_plan.png) </br>

![Alt text](https://github.com/RuslanArestov/ProjectFinalWork/blob/main/images/nginx-app.png) </br>



5. Настроил Github Actions

![Alt text](https://github.com/RuslanArestov/ProjectFinalWork/blob/main/images/github_secrets.png) </br>

Образы, помезенные в Yandex Container Registry посредством Github Actions
![Alt text](https://github.com/RuslanArestov/ProjectFinalWork/blob/main/images/YCR_docker_images_tag.png) </br>

Деплой приложения из Yandex Conrainer Registry в K8s при внесении изменений в код репозитория с приложением
![Alt text](https://github.com/RuslanArestov/ProjectFinalWork/blob/main/images/deploy_tag_v1.0.0.png) </br>
