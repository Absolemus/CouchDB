#Использовать 1connector
#Использовать entity

#Область ОписаниеПеременных
Перем Открыт; // Булево - Признак открытого соединения с БД.
Перем Сессия; // Сессия - Сессия для работы с БД. см. Сессия в 1connector.
Перем АдресБД; // Строка - Адрес БД.
#КонецОбласти

#Область ОбработчикиСобытий
Процедура ПриСозданииОбъекта()
	Открыт = Ложь;
	
КонецПроцедуры
#КонецОбласти

#Область ПрограммныйИнтерфейс
// Открыть соединение с БД.
//
// Параметры:
//   СтрокаСоединения - Строка - URL адрес базы данных.
//   ПараметрыКоннектора - Массив - Дополнительные параметры инициализации коннектора.
//
Процедура Открыть(СтрокаСоединения, ПараметрыКоннектора) Экспорт
	Сессия = Новый Сессия();
	Сессия.Заголовки["Accept"] = "application/json";
	
	ДанныеАвторизацииНайдены = Ложь;
	Авторизация = Неопределено;
	АдресБД = СтрокаСоединения;
	Для Каждого Элемент Из ПараметрыКоннектора Цикл
		
		ЭтоДанныеАвторизации = Истина
			И ТипЗнч(Элемент) = Тип("Структура")
			И Элемент.Свойство("Авторизация")
			И Элемент.Авторизация.Количество() > 0;
		
		Если ЭтоДанныеАвторизации Тогда
			ДанныеАвторизацииНайдены = Истина;
			Авторизация = Элемент.Авторизация;
		КонецЕсли;
		
	КонецЦикла;
	
	Если НЕ ДанныеАвторизацииНайдены Тогда
		// TO DO
		// Вызвать исключение и вывести в лог сообщение об отсутствии данных авторизации.
		Возврат;
	КонецЕсли;
	
	ДополнительныеПараметры = Новый Структура("JSON", Авторизация);
	Адрес = СтрШаблон("%1/_session", АдресБД);
	Ответ = Сессия.ВызватьМетод("POST", Адрес, ДополнительныеПараметры);
	Сессия.Cookies = Ответ.Cookies;
	
	Открыт = Авторизован();
КонецПроцедуры

// Закрыть соединение с БД.
//
Процедура Закрыть() Экспорт
	Адрес = СтрШаблон("%1/_session", АдресБД);
	Ответ = Сессия.ВызватьМетод("DELETE", Адрес);
	
	Результат = Ответ.Json();
	Открыт = Результат["userCtx"]["name"] = null;
	Сессия = Неопределено;
КонецПроцедуры

// Получить статус соединения с БД.
//
//  Возвращаемое значение:
//   Булево - Состояние соединения. Истина, если соединение установлено и готово к использованию.
//       В обратном случае - Ложь.
//
Функция Открыт() Экспорт
	Возврат Сессия <> Неопределено И Авторизован();
КонецФункции

// Сохраняет сущность в БД.
//
// Параметры:
//   ОбъектМодели - ОбъектМодели - Объект, содержащий описание класса-сущности и настроек таблицы БД.
//   Сущность - Произвольный - Объект (экземпляр класса, зарегистрированного в модели) для сохранения в БД.
//
Процедура Сохранить(ОбъектМодели, Сущность) Экспорт
	// TO DO
	// Реализовать наполнение пользовательских полей, которые описаны в ОбъектМодели.
	
	Если ОбъектМодели.ТипСущности() = тип("БазаДанных") Тогда
		СохранитьБазуДанных(Сущность);
	ИначеЕсли ОбъектМодели.ТипСущности() = тип("Документ") Тогда
		СохранитьДокумент(Сущность);
	ИначеЕсли ОбъектМодели.ТипСущности() = тип("Вложение") Тогда
		СохранитьВложение(Сущность);
	Иначе
		// TO DO
		// Вызвать исключение и вывести в лог сообщение о невозможности сохранения сущности.
		Возврат;
	КонецЕсли;
КонецПроцедуры

// Удаляет сущность из таблицы БД.
//
// Параметры:
//   ОбъектМодели - ОбъектМодели - Объект, содержащий описание класса-сущности и настроек таблицы БД.
//   Сущность - Произвольный - Объект (экземпляр класса, зарегистрированного в модели) для удаления из БД.
//
Процедура Удалить(ОбъектМодели, Сущность) Экспорт
	Если ОбъектМодели.ТипСущности() = тип("БазаДанных") Тогда
		УдалитьБазуДанных(Сущность.Имя);
	ИначеЕсли ОбъектМодели.ТипСущности() = тип("Документ") Тогда
		УдалитьДокумент(Сущность);
	ИначеЕсли ОбъектМодели.ТипСущности() = тип("Вложение") Тогда
		УдалитьВложение(Сущность);
	Иначе
		// TO DO
		// Вызвать исключение и вывести в лог сообщение о невозможности удаления сущности.
		Возврат;
	КонецЕсли;
КонецПроцедуры

// Осуществляет поиск строк в таблице по указанному отбору.
//
// Параметры:
//   ОбъектМодели - ОбъектМодели - Объект, содержащий описание класса-сущности и настроек таблицы БД.
//   Отбор - Массив - Отбор для поиска. Каждый элемент массива должен иметь тип "ЭлементОтбора".
//       Каждый элемент отбора преобразуется к условию поиска. В качестве "ПутьКДанным" указываются имена колонок.
//
//  Возвращаемое значение:
//   Массив - Массив, элементами которого являются "Соответствия". Ключом элемента соответствия является имя колонки,
//     значением элемента соответствия - значение колонки.
//
Функция НайтиСтрокиВТаблице(ОбъектМодели, Отбор = Неопределено) Экспорт
	Если ОбъектМодели.ТипСущности() = тип("БазаДанных") Тогда
		Возврат ПолучитьБазыДанных(Отбор);
	ИначеЕсли ОбъектМодели.ТипСущности() = тип("Документ") Тогда
		Возврат ПолучитьДокументы(Отбор);
	ИначеЕсли ОбъектМодели.ТипСущности() = тип("Вложение") Тогда
		Возврат ПолучитьВложения(Отбор);
	Иначе
		// TO DO
		// Вызвать исключение и вывести в лог сообщение о невозможности получения сущности.
		Возврат Новый Массив;
	КонецЕсли;
КонецФункции
#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция Авторизован()
	Адрес = СтрШаблон("%1/_session", АдресБД);
	Ответ = Сессия.ВызватьМетод("GET", Адрес);
	
	Результат = Ответ.Json();
	Возврат Результат["userCtx"]["name"] <> null;
КонецФункции

#Область БазаДанных
Процедура СохранитьБазуДанных(БазаДанных)
	Если НЕ БазаДанныхСуществует(БазаДанных.Имя) Тогда
		// TO DO
		// Вывести в лог сообщение о создании новой БД.
		СоздатьБазуДанных(БазаДанных.Имя);
	Иначе
		ВызватьИсключение СтрШаблон("База данных с именем %1 уже существует.", БазаДанных.Имя);
	КонецЕсли;
КонецПроцедуры

Функция БазаДанныхСуществует(ИмяБазыДанных)
	Адрес = СтрШаблон("%1/%2", АдресБД, ИмяБазыДанных);
	Ответ = Сессия.ВызватьМетод("HEAD", Адрес);
	
	// TO DO
	// Избавиться от магического числа
	Возврат Ответ.КодСостояния = 200;
КонецФункции

Процедура СоздатьБазуДанных(ИмяБазыДанных)
	Адрес = СтрШаблон("%1/%2", АдресБД, ИмяБазыДанных);
	Ответ = Сессия.ВызватьМетод("PUT", Адрес);
	
	// TO DO
	// Избавиться от магических чисел
	БазаДанныхСоздана = Ответ.КодСостояния = 200 ИЛИ Ответ.КодСостояния = 201;
	
	Если НЕ БазаДанныхСоздана Тогда
		// TO DO
		// Вызвать исключение и вывести в лог сообщение о невозможности создания БД.
	КонецЕсли;
КонецПроцедуры

Процедура УдалитьБазуДанных(ИмяБазыДанных)
	Если НЕ БазаДанныхСуществует(ИмяБазыДанных) Тогда
		// TO DO
		// Вывести в лог сообщение о невозможности удаления БД.
		ВызватьИсключение СтрШаблон("База данных с именем %1 не существует.", ИмяБазыДанных);
	КонецЕсли;
	
	Адрес = СтрШаблон("%1/%2", АдресБД, ИмяБазыДанных);
	Ответ = Сессия.ВызватьМетод("DELETE", Адрес);
	
	// TO DO
	// Избавиться от магических чисел
	БазаДанныхУдалена = Ответ.КодСостояния = 200 ИЛИ Ответ.КодСостояния = 201;
	
	Если НЕ БазаДанныхУдалена Тогда
		// TO DO
		// Вызвать исключение и вывести в лог сообщение о невозможности удаления БД.
	КонецЕсли;
КонецПроцедуры

Функция ПолучитьБазыДанных(Отбор)
	МассивИменБазДанных = Новый Массив;

	Для Каждого Элемент Из Отбор Цикл
		Если Элемент.ПутьКДанным = "Имя" Тогда
			МассивИменБазДанных.Добавить(Элемент.Значение);
		Иначе
			// TO DO
			// Вывести в лог сообщение о неверном отборе.
			ВызватьИсключение "Отбор для баз данных можно задавать только по полю Имя.";
		КонецЕсли;
	КонецЦикла;

	Если МассивИменБазДанных.Количество() = 0 Тогда
		Адрес = СтрШаблон("%1/_all_dbs", АдресБД);
		Ответ = Сессия.ВызватьМетод("GET", Адрес);
	Иначе
		Ключи = Новый Структура("keys", МассивИменБазДанных);
		ДополнительныеПараметры = Новый Структура("JSON", Ключи);
		Адрес = СтрШаблон("%1/_dbs_info", АдресБД);
		Ответ = Сессия.ВызватьМетод("POST", Адрес, ДополнительныеПараметры);
	КонецЕсли;
	
	Если Истина
		И Ответ.КодСостояния <> 200
		И Ответ.КодСостояния <> 201 Тогда
		// TO DO
		// Вызвать исключение и вывести в лог сообщение о невозможности сохранения сущности.
		ВызватьИсключение СтрШаблон("Не удалось получить список баз данных. Код состояния: %1", Ответ.КодСостояния);
	КонецЕсли;
	
	Тело = Ответ.Текст();
	
	Чтение = Новый ЧтениеJSON();
	Чтение.УстановитьСтроку(Тело);
	Данные = ПрочитатьJSON(Чтение, Истина);
	Чтение.Закрыть();
	
	МассивЗначений = Новый Массив;
	
	Для Каждого ОписаниеБазы Из Данные Цикл
		Если ОписаниеБазы["info"] <> Неопределено Тогда
			База = Новый Соответствие;
			База.Вставить("Имя", ОписаниеБазы["info"]["db_name"]);
			База.Вставить("Размер", ОписаниеБазы["info"]["sizes"]);
			База.Вставить("КоличествоДокументов", ОписаниеБазы["info"]["doc_count"]);

			МассивЗначений.Добавить(База);
		КонецЕсли;
	КонецЦикла;
	
	Возврат МассивЗначений;
КонецФункции
#КонецОбласти

#Область Документ
Процедура СохранитьДокумент(Документ)
	Если Не ЗначениеЗаполнено(Документ.Имя) Тогда
		// TO DO
		// Вывести в лог сообщение о неверном отборе.
		ВызватьИсключение "Документ должен содержать имя.";
	КонецЕсли;

	Если НЕ БазаДанныхСуществует(Документ.БазаДанных) Тогда
		// TO DO
		// Вывести в лог сообщение о невозможности сохранения документа. Избавиться от исключения
		ВызватьИсключение СтрШаблон("База данных с именем %1 не существует.", Документ.БазаДанных);
	КонецЕсли;
	
	Если НЕ ДокументСуществует(Документ.БазаДанных, Документ) Тогда
		// TO DO
		// Вывести в лог сообщение о создании нового документа.
		СоздатьДокумент(Документ.БазаДанных, Документ);
	КонецЕсли;
	
	// TO DO
	// Добавить возможность изменения существующих документов
КонецПроцедуры

Процедура УдалитьДокумент(Документ)
	Если НЕ БазаДанныхСуществует(Документ.БазаДанных.Имя) Тогда
		// TO DO
		// Вывести в лог сообщение о невозможности удаления документа. Избавиться от исключения
		ВызватьИсключение СтрШаблон("База данных с именем %1 не существует.", Документ.БазаДанных.Имя);
	КонецЕсли;
	
	Если НЕ ДокументСуществует(Документ.БазаДанных.Имя, Документ) Тогда
		// TO DO
		// Вывести в лог сообщение о невозможности удаления документа.
		ВызватьИсключение СтрШаблон("Документ с идентификатором %1 не существует.", Документ.Идентификатор);
	КонецЕсли;
	
	Адрес = СтрШаблон("%1/%2", АдресБД, Документ.Имя);
	Ответ = Сессия.ВызватьМетод("DELETE", Адрес);
	
	// TO DO
	// Избавиться от магических чисел
	ДокументУдален = Ответ.КодСостояния = 200 ИЛИ Ответ.КодСостояния = 201;
	
	Если НЕ ДокументУдален Тогда
		// TO DO
		// Вызвать исключение и вывести в лог сообщение о невозможности удаления документа.
	КонецЕсли;
КонецПроцедуры

Процедура СоздатьДокумент(ИмяБазыДанных, Документ)
	Адрес = СтрШаблон("%1/%2/%3", АдресБД, ИмяБазыДанных, Документ.Идентификатор);
	ДополнительныеПараметры = Новый Структура("JSON", Новый Соответствие);
	ДополнительныеПараметры.JSON.Вставить("Имя", Документ.Имя);
	Ответ = Сессия.ВызватьМетод("PUT", Адрес, ДополнительныеПараметры);
	
	// TO DO
	// Избавиться от магических чисел
	ДокументСоздан = Ответ.КодСостояния = 200 ИЛИ Ответ.КодСостояния = 201;
	
	Если НЕ ДокументСоздан Тогда
		// TO DO
		// Вызвать исключение и вывести в лог сообщение о невозможности создания документа.
	КонецЕсли;
КонецПроцедуры

Функция ДокументСуществует(ИмяБазыДанных, ИмяДокумента)
	Адрес = СтрШаблон("%1/%2/%3", АдресБД, ИмяБазыДанных, ИмяДокумента);
	Ответ = Сессия.ВызватьМетод("HEAD", Адрес);
	
	// TO DO
	// Избавиться от магического числа
	Возврат Ответ.КодСостояния = 200;
КонецФункции

Функция ПолучитьДокументы(Отбор)
	БазаДанных = Неопределено;
	Селектор = Новый Структура("selector", Новый Соответствие);
	Для Каждого Элемент Из Отбор Цикл
		Если Элемент.ПутьКДанным = "Идентификатор" Тогда
			Селектор.selector.Вставить("_id", Элемент.Значение);
		ИначеЕсли Элемент.ПутьКДанным = "Ревизия" Тогда
			Селектор.selector.Вставить("_rev", Элемент.Значение);
		ИначеЕсли Элемент.ПутьКДанным = "БазаДанных" Тогда
			БазаДанных = Элемент.Значение;
		Иначе
			Селектор.selector.Вставить(Элемент.ПутьКДанным, Элемент.Значение);
		КонецЕсли;	
	КонецЦикла;

	Если БазаДанных = Неопределено Тогда
		// TO DO
		// Вывести в лог сообщение о неверном отборе.
		ВызватьИсключение "Отбор для документов должен содержать элемент с путем к данным БазаДанных.";
	КонецЕсли;

	Если Не БазаДанныхСуществует(БазаДанных) Тогда
		// TO DO
		// Вывести в лог сообщение о невозможности получения документов. Избавиться от исключения
		ВызватьИсключение СтрШаблон("База данных с именем %1 не существует.", БазаДанных);
	КонецЕсли;

	Адрес = СтрШаблон("%1/%2/_find", АдресБД, БазаДанных);
	Если Селектор.selector.Количество() = 0 Тогда
		Ответ = Сессия.ВызватьМетод("POST", Адрес);
	Иначе
		ДополнительныеПараметры = Новый Структура("JSON", Селектор);
		Ответ = Сессия.ВызватьМетод("POST", Адрес, ДополнительныеПараметры);
	КонецЕсли;

	Если Истина
		И Ответ.КодСостояния <> 200
		И Ответ.КодСостояния <> 201 Тогда
		// TO DO
		// Вызвать исключение и вывести в лог сообщение о невозможности сохранения сущности.
		ВызватьИсключение СтрШаблон("Не удалось получить список документов. Код состояния: %1", Ответ.КодСостояния);
	КонецЕсли;

	Тело = Ответ.Текст();

	Чтение = Новый ЧтениеJSON();
	Чтение.УстановитьСтроку(Тело);
	Данные = ПрочитатьJSON(Чтение, Истина);
	Чтение.Закрыть();

	МассивЗначений = Новый Массив;

	Если Данные["docs"] = Неопределено Тогда
		Возврат МассивЗначений;
	КонецЕсли;

	Для Каждого ОписаниеДокумента Из Данные["docs"] Цикл
		Документ = Новый Соответствие;
		Документ.Вставить("Идентификатор", ОписаниеДокумента["_id"]);
		Документ.Вставить("Ревизия", ОписаниеДокумента["_rev"]);
		Документ.Вставить("Имя", ОписаниеДокумента["Имя"]);
		Документ.Вставить("БазаДанных", БазаДанных);
		МассивЗначений.Добавить(Документ);
	КонецЦикла;

	Возврат МассивЗначений;
КонецФункции
#КонецОбласти

#Область Вложение
Процедура СохранитьВложение(Вложение)
	Если НЕ БазаДанныхСуществует(Вложение.Документ.БазаДанных.Имя) Тогда
		// TO DO
		// Вывести в лог сообщение о невозможности сохранения документа. Избавиться от исключения
		ВызватьИсключение СтрШаблон("База данных с именем %1 не существует.", Вложение.Документ.БазаДанных.Имя);
	КонецЕсли;
	
	Если НЕ ДокументСуществует(Вложение.Документ.БазаДанных.Имя, Вложение.Документ.Имя) Тогда
		// TO DO
		// Вывести в лог сообщение о создании нового документа.
		ВызватьИсключение СтрШаблон("Документ с именем %1 не существует.", Вложение.Документ.Имя);
	КонецЕсли;
	
	Адрес = СтрШаблон("%1/%2/%3", АдресБД, Вложение.БазаДанных.Имя, Вложение.Документ.Имя);
	
	Если ЗначениеЗаполнено(Вложение.Документ.Ревизия) Тогда
		Адрес = СтрШаблон("%1?rev=%2", Адрес, Вложение.Документ.Ревизия);
	КонецЕсли;
	
	ДополнительныеПараметры = Новый Структура;
	Заголовки = Новый Соответствие;
	Заголовки.Вставить("Accept", "application/json");
	ДополнительныеПараметры.Добавить("Заголовки", Заголовки);
	ДополнительныеПараметры.Добавить("Данные", Вложение.Данные);
	
	Если ТипЗнч(Вложение.Данные) = тип("Строка") Тогда
		Заголовки.Вставить("Content-Type", "text/plain");
	ИначеЕсли ТипЗнч(Вложение.Данные) = Тип("ДвоичныеДанные") Тогда
		Заголовки.Вставить("Content-Type", "application/octet-stream");
	Иначе
		Заголовки.Вставить("Content-Type", "application/json");
	КонецЕсли;
	
	Ответ = Сессия.ВызватьМетод("PUT", Адрес, ДополнительныеПараметры);
	
	Если Истина
		И Ответ.КодСостояния <> 200
		И Ответ.КодСостояния <> 201 Тогда
		// TO DO
		// Вызвать исключение и вывести в лог сообщение о невозможности сохранения сущности.
	КонецЕсли;
	
КонецПроцедуры

Процедура УдалитьВложение(Вложение)
	Если НЕ БазаДанныхСуществует(Вложение.Документ.БазаДанных.Имя) Тогда
		// TO DO
		// Вывести в лог сообщение о невозможности сохранения документа. Избавиться от исключения
		ВызватьИсключение СтрШаблон("База данных с именем %1 не существует.", Вложение.Документ.БазаДанных.Имя);
	КонецЕсли;
	
	Если НЕ ДокументСуществует(Вложение.Документ.БазаДанных.Имя, Вложение.Документ.Имя) Тогда
		// TO DO
		// Вывести в лог сообщение о создании нового документа.
		ВызватьИсключение СтрШаблон("Документ с именем %1 не существует.", Вложение.Документ.Имя);
	КонецЕсли;
	
	Адрес = СтрШаблон("%1/%2/%3/%4", АдресБД, Вложение.Документ.БазаДанных.Имя, Вложение.Документ.Имя, Вложение.Имя);
	
	Если ЗначениеЗаполнено(Вложение.Документ.Ревизия) Тогда
		Адрес = СтрШаблон("%1?rev=%2", Адрес, Вложение.Документ.Ревизия);
	КонецЕсли;
	
	Ответ = Сессия.ВызватьМетод("DELETE", Адрес);
	
	Если Истина
		И Ответ.КодСостояния <> 200
		И Ответ.КодСостояния <> 201 Тогда
		// TO DO
		// Вызвать исключение и вывести в лог сообщение о невозможности сохранения сущности.
	КонецЕсли;
КонецПроцедуры

Функция ПолучитьВложения(Отбор) 
	БазаДанных = Неопределено;
	Документ = Неопределено;
	ИмяВложения = Неопределено;
	ДополнительныеПараметры = Новый Структура("selector", Новый Соответствие);
	Для Каждого Элемент Из Отбор Цикл
		Если Элемент.ПутьКДанным = "Имя" Тогда
			ИмяВложения = Элемент.Значение;
		ИначеЕсли Элемент.ПутьКДанным = "БазаДанных" Тогда
			БазаДанных = Элемент.Значение;
		ИначеЕсли Элемент.ПутьКДанным = "Документ" Тогда
			Документ = Элемент.Значение;
		Иначе
			ДополнительныеПараметры.selector.Вставить(Элемент.ПутьКДанным, Элемент.Значение);
		КонецЕсли;	
	КонецЦикла;

	Если БазаДанных = Неопределено Тогда
		// TO DO
		// Вывести в лог сообщение о неверном отборе.
		ВызватьИсключение "Отбор для вложений должен содержать элемент с путем к данным БазаДанных.";
	КонецЕсли;

	Если Документ = Неопределено Тогда
		// TO DO
		// Вывести в лог сообщение о неверном отборе.
		ВызватьИсключение "Отбор для вложений должен содержать элемент с путем к данным Документ.";
	КонецЕсли;

	Если Не БазаДанныхСуществует(БазаДанных) Тогда
		// TO DO
		// Вывести в лог сообщение о невозможности получения документов. Избавиться от исключения
		ВызватьИсключение СтрШаблон("База данных с именем %1 не существует.", БазаДанных);
	КонецЕсли;

	Если НЕ ДокументСуществует(БазаДанных, Документ) Тогда
		// TO DO
		// Вывести в лог сообщение о невозможности получения документов. Избавиться от исключения
		ВызватьИсключение СтрШаблон("Документ с именем %1 не существует.", Документ);
	КонецЕсли;

	Адрес = СтрШаблон("%1/%2/%3/%4", АдресБД, БазаДанных, Документ, ИмяВложения);
	Ответ = Сессия.ВызватьМетод("GET", Адрес);

	Если Истина
		И Ответ.КодСостояния <> 200
		И Ответ.КодСостояния <> 201 Тогда
		// TO DO
		// Вызвать исключение и вывести в лог сообщение о невозможности сохранения сущности.
		ВызватьИсключение СтрШаблон("Не удалось получить список вложений. Код состояния: %1", Ответ.КодСостояния);
	КонецЕсли;

	Тело = Ответ.Текст();

	Чтение = Новый ЧтениеJSON();
	Чтение.УстановитьСтроку(Тело);
	Данные = ПрочитатьJSON(Чтение, Истина);
	Чтение.Закрыть();

	МассивЗначений = Новый Массив;
	Поля = Новый Соответствие;
	Поля.Вставить("Имя", ИмяВложения);
	Поля.Вставить("Данные", Данные);

	МассивЗначений.Добавить(Поля);

	Возврат МассивЗначений;
КонецФункции
#КонецОбласти

#КонецОбласти

#Область НеРеализованныеПроцедурыИФункции
// Начинает новую транзакцию в БД.
//
Процедура НачатьТранзакцию() Экспорт
	
КонецПроцедуры

// Фиксирует открытую транзакцию в БД.
//
Процедура ЗафиксироватьТранзакцию() Экспорт
	
КонецПроцедуры

// Отменяет открытую транзакцию в БД.
//
Процедура ОтменитьТранзакцию() Экспорт
	
КонецПроцедуры

// Создает таблицу в БД по данным модели.
//
// Параметры:
//   ОбъектМодели - ОбъектМодели - Объект, содержащий описание класса-сущности и настроек таблицы БД.
//
Процедура ИнициализироватьТаблицу(ОбъектМодели) Экспорт
	
КонецПроцедуры

// Удаляет строки в таблице по указанному отбору.
//
// Параметры:
//   ОбъектМодели - ОбъектМодели - Объект, содержащий описание класса-сущности и настроек таблицы БД.
//   Отбор - Массив - Отбор для поиска. Каждый элемент массива должен иметь тип "ЭлементОтбора".
//       Каждый элемент отбора преобразуется к условию поиска. В качестве "ПутьКДанным" указываются имена колонок.
//
Процедура УдалитьСтрокиВТаблице(ОбъектМодели, Знач Отбор) Экспорт
	
КонецПроцедуры
#КонецОбласти