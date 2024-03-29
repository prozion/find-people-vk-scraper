# Рекомендации по заполнению списка групп

Наша задача состоит в том, чтобы выявить и опросить как можно больше людей, которые
- потенциально заинтересованы посещать марксистский кружок
- живут в городе N
- имеют аккаунт во вконтакте

Для этого мы ищем аккаунты вконтакте, которые одновременно подписаны как на (около)марксистские паблики, так и на городские паблики. [Скрипт](cmd/search_users_by_intersection.rkt) находит данные пересечения, а затем автоматически генерирует таблицу с ссылками на искомые аккаунты. Но ей требуется список пабликов.

Список (около)марксистских групп [уже готов](https://github.com/prozion/red-kgr/blob/main/sn.tree). Однако список местных групп для каждого нового города необходимо каждый раз формировать вручную.

## Как искать местные группы?

* Вбить в поиске сообществ VK название города. Например, [результаты для города Севастополь](https://vk.com/groups?act=catalog&c[per_page]=40&c[q]=Севастополь&c[section]=communities&c[sort]=6)
* Другой вариант: выбрать этот город в параметрах поиска
* Более трудоемкий вариант, но выявляющий более актуальные паблики: выбрать в одной из местных групп человека и посмотреть в его подписках местные паблики.

Желательно добавлять в список группы разной тематики, а не одной. Не надо включать, скажем, одни лишь барахолки и доски объявлений. Пусть будут также группы местных школ, музеев, спортивных клубов, Подслушано и т.д.

* В списке нужны группы не слишком большие и не слишком маленькие, хорошо, когда в паблике от 1000 до 100.000 подписчиков.
* Пабликов в списке желательно иметь не менее 100. Так местных найдем с большей надежностью.

## В каком виде список?

В текстовом файле, одна строка - одна группа. В формате

`<Название группы> <http ссылка на группу> <Число участников>`

Например:

```
...
Библиотека им. Л. Н. Толстого (Севастополь) https://vk.com/svlib 3681
Черный список СЕВАСТОПОЛЬ https://vk.com/sev.blacklist 131793
Херсонес Таврический в Севастополе https://vk.com/chersonesos_sev 14516
...
```

## Куда присылать результат?

Текстовый файл присылайте в личные сообщения на https://vk.com/denis.shirshov
