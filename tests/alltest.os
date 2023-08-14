#Использовать asserts
#Использовать entity
#Использовать ".."

Перем ИмяБД;
Перем ИмяДокумента;
Перем ИмяВложения;
Перем ТекстовыеДанныеВложения;
Перем ДвоичныеДанныеВложения;
Перем ХранилищеБазДанных;
Перем ХранилищеДокументов;
Перем ХранилищеВложений;

#Область ПередИПосле
&Перед
Процедура ПередЗапускомТеста() Экспорт	
	Авторизация = Новый Структура("name, password", "admin", "password");

	Ответ = КоннекторHTTP.Post("localhost:5984/_session", , Авторизация);
	Параметры = Новый Структура("Cookies", Ответ.Cookies);
	Ответ = КоннекторHTTP.Put("localhost:5984/test/", , , Параметры);

	ПараметрыКоннектора = Новый Массив;
	ПараметрыКоннектора.Добавить(Новый Структура("Авторизация", Авторизация));
	МенеджерСущностей = Новый МенеджерСущностей(Тип("КоннекторCouchDB"), "http://localhost:5984", ПараметрыКоннектора);
	МенеджерСущностей.ДобавитьКлассВМодель(Тип("БазаДанных"));
	МенеджерСущностей.ДобавитьКлассВМодель(Тип("Документ"));
	МенеджерСущностей.ДобавитьКлассВМодель(Тип("Вложение"));
	МенеджерСущностей.Инициализировать();

	ХранилищеБазДанных = МенеджерСущностей.ПолучитьХранилищеСущностей(Тип("БазаДанных"));
	ХранилищеДокументов = МенеджерСущностей.ПолучитьХранилищеСущностей(Тип("Документ"));
	ХранилищеВложений = МенеджерСущностей.ПолучитьХранилищеСущностей(Тип("Вложение"));

КонецПроцедуры

&После
Процедура ПослеЗапускаТеста() Экспорт
	Авторизация = Новый Структура("name, password", "admin", "password");

	Ответ = КоннекторHTTP.Post("localhost:5984/_session", , Авторизация);
	Параметры = Новый Структура("Cookies", Ответ.Cookies);
	Ответ = КоннекторHTTP.Delete("localhost:5984/test/", , , Параметры);
КонецПроцедуры
#КонецОбласти

&Тест
Процедура СозданиеБазыДанных() Экспорт
	ТекущаяБазаДанных = ХранилищеБазДанных.СоздатьЭлемент();
	ТекущаяБазаДанных.Имя = "new_data_base";
	ТекущаяБазаДанных.Сохранить();

	ПолученнаяСущность = ХранилищеБазДанных.ПолучитьОдно("new_data_base");
	Ожидаем.Что(ПолученнаяСущность.Имя).Равно("new_data_base");

	Авторизация = Новый Структура("name, password", "admin", "password");

	Ответ = КоннекторHTTP.Post("localhost:5984/_session", , Авторизация);
	Параметры = Новый Структура("Cookies", Ответ.Cookies);
	Ответ = КоннекторHTTP.Delete("localhost:5984/new_data_base/", , , Параметры);
КонецПроцедуры

&Тест
Процедура СозданиеДокумента() Экспорт
	ТекущийДокумент = ХранилищеДокументов.СоздатьЭлемент();
	ТекущийДокумент.Имя = ИмяДокумента;
	ТекущийДокумент.БазаДанных = ХранилищеБазДанных.ПолучитьОдно(ИмяБД).Имя;
	ТекущийДокумент.Сохранить();

	Отбор = Новый Массив;
	Отбор.Добавить(Новый ЭлементОтбора("Имя", ВидСравнения.Равно, ИмяДокумента));
	Отбор.Добавить(Новый ЭлементОтбора("БазаДанных", ВидСравнения.Равно, ХранилищеБазДанных.ПолучитьОдно(ИмяБД).Имя));
	ПолученнаяСущность = ХранилищеДокументов.ПолучитьОдно(Отбор);
	Ожидаем.Что(ПолученнаяСущность.Имя).Равно(ИмяДокумента);
КонецПроцедуры

&Тест
Процедура ПолучениеСуществующегоДокументаЧерезОтбор() Экспорт
	Авторизация = Новый Структура("name, password", "admin", "password");

	Ответ = КоннекторHTTP.Post("localhost:5984/_session", , Авторизация);
	Параметры = Новый Структура("Cookies", Ответ.Cookies);
	Параметры.Вставить("JSON", Новый Структура("Имя", ИмяДокумента));
	Ответ = КоннекторHTTP.Put("localhost:5984/test/" + ИмяДокумента + "/", , , Параметры);

	Отбор = Новый Массив;
	Отбор.Добавить(Новый ЭлементОтбора("Имя", ВидСравнения.Равно, ИмяДокумента));
	Отбор.Добавить(Новый ЭлементОтбора("БазаДанных", ВидСравнения.Равно, ХранилищеБазДанных.ПолучитьОдно(ИмяБД).Имя));
	ПолученнаяСущность = ХранилищеДокументов.ПолучитьОдно(Отбор);
	Ожидаем.Что(ПолученнаяСущность.Имя).Равно(ИмяДокумента);

КонецПроцедуры

&Тест
Процедура СозданиеВложенияСоСтрокой() Экспорт
	Авторизация = Новый Структура("name, password", "admin", "password");

	Ответ = КоннекторHTTP.Post("localhost:5984/_session", , Авторизация);
	Параметры = Новый Структура("Cookies", Ответ.Cookies);
	Параметры.Вставить("JSON", Новый Структура("Имя", ИмяДокумента));
	Ответ = КоннекторHTTP.Put("localhost:5984/test/" + ИмяДокумента + "/", , , Параметры);

	ТекущееВложение = ХранилищеВложений.СоздатьЭлемент();
	ТекущееВложение.Имя = ИмяВложения;
	ТекущееВложение.Документ = ИмяДокумента;
	ТекущееВложение.БазаДанных = ИмяБД;
	ТекущееВложение.ТипДанных = Тип("Строка");
	ТекущееВложение.ДанныеСтрока = ТекстовыеДанныеВложения;
	ТекущееВложение.Сохранить();

	Отбор = Новый Массив;
	Отбор.Добавить(Новый ЭлементОтбора("Имя", ВидСравнения.Равно, ИмяВложения));
	Отбор.Добавить(Новый ЭлементОтбора("Документ", ВидСравнения.Равно, ИмяДокумента));
	Отбор.Добавить(Новый ЭлементОтбора("БазаДанных", ВидСравнения.Равно, ИмяБД));
	ПолученнаяСущность = ХранилищеВложений.ПолучитьОдно(Отбор);
	Ожидаем.Что(ПолученнаяСущность.Имя).Равно(ИмяВложения);
	Ожидаем.Что(ПолученнаяСущность.ДанныеСтрока).Равно(ТекстовыеДанныеВложения);

КонецПроцедуры

&Тест
Процедура СозданиеВложенияСДвоичнымиДанными() Экспорт
	Авторизация = Новый Структура("name, password", "admin", "password");

	Ответ = КоннекторHTTP.Post("localhost:5984/_session", , Авторизация);
	Параметры = Новый Структура("Cookies", Ответ.Cookies);
	Параметры.Вставить("JSON", Новый Структура("Имя", ИмяДокумента));
	Ответ = КоннекторHTTP.Put("localhost:5984/test/" + ИмяДокумента + "/", , , Параметры);

	ТекущееВложение = ХранилищеВложений.СоздатьЭлемент();
	ТекущееВложение.Имя = ИмяВложения;
	ТекущееВложение.Документ = ИмяДокумента;
	ТекущееВложение.БазаДанных = ИмяБД;
	ТекущееВложение.ТипДанных = Тип("ДвоичныеДанные");
	ТекущееВложение.ДвоичныеДанные = ДвоичныеДанныеВложения;
	ТекущееВложение.Сохранить();

	Отбор = Новый Массив;
	Отбор.Добавить(Новый ЭлементОтбора("Имя", ВидСравнения.Равно, ИмяВложения));
	Отбор.Добавить(Новый ЭлементОтбора("Документ", ВидСравнения.Равно, ИмяДокумента));
	Отбор.Добавить(Новый ЭлементОтбора("БазаДанных", ВидСравнения.Равно, ИмяБД));
	ПолученнаяСущность = ХранилищеВложений.ПолучитьОдно(Отбор);
	Ожидаем.Что(ПолученнаяСущность.Имя).Равно(ИмяВложения);
	Ожидаем.Что(ПолученнаяСущность.ДвоичныеДанные).Равно(ДвоичныеДанныеВложения);

КонецПроцедуры

ИмяБД = "test";
ИмяДокумента = "newDocument";
ИмяВложения = "newAttachment";
ТекстовыеДанныеВложения = "Hello, World!";
ДвоичныеДанныеВложения = ПолучитьДвоичныеДанныеИзСтроки(ТекстовыеДанныеВложения);
// oscript.exe .\tasks\coverage.os - для запуска ковереджа