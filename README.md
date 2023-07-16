## Поиск юзеров ВК по пересечению интересов

В данном репозитории содержатся скрипты, которые производят поиск пользователей сети ВКонтакте, исходя из их интересов. Интерес определяется как подписка на паблики той или иной тематической группы.

Ниже дается инструкция как установить скрипт локально у себя на компе (под Linux Ubuntu), как заполнить данные о тематических группах, как запустить скрипты и как использовать результат их работы.

### Установка Racket

Racket - мощный язык написания скриптов для работы с данными. Развивается в основном в американской академической среде, в индустрии ПО и Data Science используется реже по историческим ([зима Искуственного Интеллекта](https://ru.wikipedia.org/wiki/%D0%97%D0%B8%D0%BC%D0%B0_%D0%B8%D1%81%D0%BA%D1%83%D1%81%D1%81%D1%82%D0%B2%D0%B5%D0%BD%D0%BD%D0%BE%D0%B3%D0%BE_%D0%B8%D0%BD%D1%82%D0%B5%D0%BB%D0%BB%D0%B5%D0%BA%D1%82%D0%B0)) и корпоративным причинам (засилье монополий типа Oracle и Microsoft).

Рекомендуется устанавливать язык, предварительно скачав скрипт установки с [сайта разработчика](https://racket-lang.org/download/).

После загрузки файла, дать ему права на исполнение и запустить:

`$ chmod +x racket-8.9-x86_64-linux-cs.sh`[^1]

`$ ./racket-8.9-x86_64-linux-cs.sh`



#### Установка необходимых библиотек

* Odysseus
* Tabtree

### Заполнение списка групп в формате Tabtree

#### Установка редактора кода Atom

##### Установка подсветки синтаксиса Tabtree

### Запускаем скрипты

Рассмотрим порядок действий на примере поиска левых в Ростове-на-Дону

#### Подготовка. Изменение настроек скриптов

...

Также перед запуском необходимо создать директорию
`$ mkdir -p /var/cache/projects/find-people/rostov_red`

#### Непосредственный запуск скриптов

Переходим в директорию со скриптами:

`cd <project-path>/cmd` [^2]

Запускаем три скрипта, один за другим:

- `racket update-items.rkt`
- `racket score-uids.rkt`
- `racket search_users_by_intersection.rkt`

Выполнение первого и третьего скрипта может занять много времени (несколько десятков минут), так что держите томик работ Ленина под рукой

В итоге в `/var/cache/projects/find-people/rostov_red` появится файл `rostov_in_red_groups.csv`.

#### Делаем google таблицу

Теперь csv файл нужно загрузить в электронную таблицу google drive.

...


[^1]: Символ $ означает ввод командной строки в bash
[^2]: <project-path> подразумевает полный путь к директории проекта, в моем случае команда имеет вид `cd ~/projects/search-people/cmd`
