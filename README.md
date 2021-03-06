# Teachbase Metrix Collector

Библиотека для поддержки обновления собираемых метрик иерархичной вложенности

## Установка

Для установки библиотеки в проект, добавьте следующую строку в Gemfile:

```ruby
gem 'teachbase_metrix_collector', github: 'MikeYu123/teachbase_metrix_collector'
```

И запустите команду `bundle install` (необходим установленный gem __bundler__)

## Зависимости
Данный gem опирается на ruby 2.4.0 & rails 5.1.1, в частности, следующие составляющие:
* ActiveSupport (используются расширения для классов стандартной библиотеки Ruby)
* ActiveRecord (ключевая функциональность библиотеки является расширением для моделей ActiveRecord)
* ActiveJob (для обновления моделей в фоне)
## Использование
Для использования библиотеки в rails-приложении необходимо включить модуль `Teachbase::MetrixCollector::BelongsToStat` в класс модели, изменения в которой должны повлечь изменения в родительской модели. Затем необходимо воспользоваться нотацией `belongs_to_stat`. Пример:
```ruby
class ParentStat < ActiveRecord::Base; end

class ChildStat < ActiveRecord::Base
  include Teachbase::MetrixCollector::BelongsToStat

  belongs_to_stat :parent_stat, columns: %i[score]
end
```
Синтаксис belongs_to_stat выглядит следующим образом: первым аргументом выступает имя родительской модели, затем по ключевому слову предоставляется список колонок, которые будут обновляться в родительской модели(в виде массива литералов типа `Symbol`). При этом данные колонки должны присутствовать в обеих моделях, и обе модели должны поддерживать оптимистический захват строк таблиц (optimistic locking).
## Тестирование
Функциональность протестирована с использованием Rspec и Rails-хелперов для тестирования. Для тестирования скопируйте репозиторий и запустите:
`bin/setup && bundle exec rspec` (необходим установленный ruby и gem bundler).
## Реализация
В основе реализации лежит механизм обратного вызова моделями ActiveRecord процедур при сохранении моделей.
При сохранении модели, имеющей предка, для которого отслеживаются изменения колонок, создается фоновая задача на обновление модели этого предка. Обновление происходит с использованием оптимистического захвата и посредством добавления разности между изменяемыми снимками состояния по полям, таким образом в случае, если в рамках фоновой задачи не удастся применить изменения, будет создана новая задача для обновления данной модели с той же разностью, что позволяет поддерживать консистентность без использования реальных блокировок в таблицах.
## TODO
* Поддержка операций удаления моделей (при помощи обратных вызовов на удаление)
* Поддержка отслеживания изменений в моделях с различными именами колонок в родительской и вложенной моделях
* Добавить проверку на существование моноида для типов отслеживаемых типов полей
