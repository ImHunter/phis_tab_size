﻿
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ПриКомпоновкеРезультата(ДокументРезультат, ДанныеРасшифровки, СтандартнаяОбработка)

	СтандартнаяОбработка = Ложь;   

	Если ПустаяСтрока(АдресТаблицыРазмеров) Тогда
	 	ВызватьИсключение(НСтр("ru = 'Не загружена таблица с размерами'"));
	КонецЕсли;


	НастройкиКомпоновки = КомпоновщикНастроек.ПолучитьНастройки();
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	МакетКомпоновки = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных, НастройкиКомпоновки, ДанныеРасшифровки);

	ВнешниеНаборы = Новый Структура();
	ВнешниеНаборы.Вставить("СтруктураХраненияБазыДанных", ПолучитьСтруктуруХраненияБазыДанных(, Истина));
	ВнешниеНаборы.Вставить("Размеры", ПолучитьИзВременногоХранилища(АдресТаблицыРазмеров));

	ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновки.Инициализировать(МакетКомпоновки, ВнешниеНаборы, ДанныеРасшифровки);

	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
	ПроцессорВывода.УстановитьДокумент(ДокументРезультат);
	ПроцессорВывода.Вывести(ПроцессорКомпоновки);   

КонецПроцедуры

#КонецОбласти // ОбработчикиСобытий

#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли
