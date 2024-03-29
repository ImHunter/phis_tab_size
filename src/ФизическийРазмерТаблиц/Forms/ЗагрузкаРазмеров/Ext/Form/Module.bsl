﻿
#Область ОписаниеПеременных

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	СИ = Новый СистемнаяИнформация();
	ДоступнаПлатформеннаяВыгрузка = СтрСравнить(СИ.ВерсияПриложения, "8.3.15.0")>0;
	СпособПолученияДанных = ?(ДоступнаПлатформеннаяВыгрузка, 1, 2);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	АдресДанныхФайла = ПоместитьВоВременноеХранилище(Неопределено, ВладелецФормы.УникальныйИдентификатор);
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ИмяФайлаРезультатаНачалоВыбора(Элемент, ДанныеВыбора, ВыборДобавлением, СтандартнаяОбработка)  
	
	СтандартнаяОбработка = Ложь;   
	
	ОписаниеОповещенияВыбора = Новый ОписаниеОповещения("ОбработкаВыбораФайла", ЭтотОбъект);
	
	Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	Диалог.Фильтр = "Все|*.csv;*.xls;*.xlsx|CSV|*.csv|Excel|*.xls;*.xlsx"; 
	Диалог.МножественныйВыбор = Ложь;
	
	Диалог.Показать(ОписаниеОповещенияВыбора);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура КомандаПоказатьСкрипт(Команда)
	ПоказатьВводСтроки(Новый ОписаниеОповещения, ТекстСкрипта(), "Текст скрипта", 0, Истина); 
КонецПроцедуры    

&НаКлиенте
Процедура КомандаЗагрузить(Команда)
	
	Если СпособПолученияДанных=1 Тогда 
		
		Если Не ДоступнаПлатформеннаяВыгрузка Тогда 
			ВызватьИсключение(НСтр("ru = 'Выгрузка размеров недоступна для текущей версии платформы.
			|Требуется платформа не ниже 8.3.15.'"));
		КонецЕсли;
		
	ИначеЕсли СпособПолученияДанных=2 Тогда 
		
		Если ПустаяСтрока(ИмяФайлаРезультата) Тогда
			ВызватьИсключение(НСтр("ru = 'Не указан файл с размерами'"));
		КонецЕсли;
		
		Файл = Новый Файл(ИмяФайлаРезультата);
		Если Не Файл.Существует() Тогда 
			ВызватьИсключение(НСтр("ru = 'Файл не существует: '") + ИмяФайлаРезультата);
		КонецЕсли; 
		
	Иначе
		// Ничего не делаем
	КонецЕсли;
	
	Результат = Новый Структура("ИмяФайлаРезультата, АдресДанныхФайла, ВыгрузитьПлатформой");
	ЗаполнитьЗначенияСвойств(Результат, ЭтотОбъект);
	Результат.ВыгрузитьПлатформой = СпособПолученияДанных=1;
	
	Закрыть(Результат);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Функция ТекстСкрипта()
	Возврат "CREATE TABLE #temp (
	|table_name NVARCHAR(128)
	|,row_count INT
	|,reserved_size VARCHAR(18)
	|,data_size VARCHAR(18)
	|,index_size VARCHAR(18)
	|,unused_size VARCHAR(18)
	|,reserved_size_int FLOAT
	|,data_size_int FLOAT
	|,index_size_int FLOAT
	|,unused_size_int FLOAT
	|,used_size_int FLOAT
	|)
    |
	|SET NOCOUNT ON
    |
	|INSERT #temp (
	|table_name
	|,row_count
	|,reserved_size
	|,data_size
	|,index_size
	|,unused_size
	|)
	|EXEC sp_msforeachtable 'sp_spaceused ''?'''
	|
	|UPDATE #temp
	|SET reserved_size_int = CAST(REPLACE(reserved_size, ' KB', '') AS FLOAT) / 1024
	|,data_size_int = CAST(REPLACE(data_size, ' KB', '') AS FLOAT) / 1024
	|,index_size_int = CAST(REPLACE(index_size, ' KB', '') AS FLOAT) / 1024
	|,unused_size_int = CAST(REPLACE(unused_size, ' KB', '') AS FLOAT) / 1024
	|,used_size_int = CAST(REPLACE(data_size, ' KB', '') AS FLOAT) / 1024 + CAST(REPLACE(index_size, ' KB', '') AS FLOAT) / 1024
    |
	|SELECT *
	|FROM #temp
	|ORDER BY 1
	|
	|DROP TABLE #temp";  
	
КонецФункции

&НаКлиенте
Процедура ОбработкаВыбораФайла(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт   
	
	Если Не ЗначениеЗаполнено(ВыбранныеФайлы) Тогда
		Возврат;
	КонецЕсли;   
	
	ИмяФайлаРезультата = ВыбранныеФайлы[0];
	ДвоичныеДанные = Новый ДвоичныеДанные(ИмяФайлаРезультата);
	ПоместитьВоВременноеХранилище(ДвоичныеДанные, АдресДанныхФайла);
	
КонецПроцедуры

#КонецОбласти
