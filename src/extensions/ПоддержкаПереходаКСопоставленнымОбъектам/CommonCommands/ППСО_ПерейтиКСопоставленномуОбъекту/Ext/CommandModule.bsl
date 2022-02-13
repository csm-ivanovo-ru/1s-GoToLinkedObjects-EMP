﻿#Область ОбработчикиСобытий

&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)

	НавигационнаяСсылкаПриемника = ПолучитьНавигационнуюСсылкуСопоставленногоОбъекта(ПараметрКоманды);
	ПерейтиПоНавигационнойСсылке(НавигационнаяСсылкаПриемника);

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Функция ПолучитьНавигационнуюСсылкуСопоставленногоОбъекта(ОбъектСсылка)
	Контекст = "ППСО_ПерейтиКСопоставленномуОбъекту.ПолучитьНавигационнуюСсылкуСопоставленногоОбъекта";
	
	УникальныйИдентификаторИсточника = ОбъектСсылка.УникальныйИдентификатор();
	ТипИсточника = Метаданные.НайтиПоТипу(ТипЗнч(ОбъектСсылка)).ПолноеИмя();

	// Запрос для определения информации о сопоставлении объектов для подмены ссылки источника, на ссылку приемника.
	ЗапросСоответствияОбъектовИнформационныхБаз = Новый Запрос;
	ЗапросСоответствияОбъектовИнформационныхБаз.Текст =
		"ВЫБРАТЬ ПЕРВЫЕ 1
	    |	СоответствияОбъектовИнформационныхБаз.УникальныйИдентификаторПриемника КАК УникальныйИдентификаторПриемника,
	    |	СоответствияОбъектовИнформационныхБаз.ТипПриемника КАК ТипПриемника,
		|	НастройкиТранспортаОбменаДанными.COMИмяСервера1СПредприятия КАК ИмяСервера,
		|	НастройкиТранспортаОбменаДанными.COMИмяИнформационнойБазыНаСервере1СПредприятия КАК ИмяИнформационнойБазы
	    |ИЗ
	    |	ПланОбмена.ОбменБГУ2ЕМП КАК ОбменБГУ2ЕМП
	    |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.СоответствияОбъектовИнформационныхБаз КАК СоответствияОбъектовИнформационныхБаз
    	|		ПО ОбменБГУ2ЕМП.Ссылка = СоответствияОбъектовИнформационныхБаз.УзелИнформационнойБазы
	    |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.НастройкиТранспортаОбменаДанными КАК НастройкиТранспортаОбменаДанными
    	|		ПО НастройкиТранспортаОбменаДанными.Корреспондент = ОбменБГУ2ЕМП.Ссылка
	    |ГДЕ
	    |	НЕ( ОбменБГУ2ЕМП.ЭтотУзел )
	    |	И СоответствияОбъектовИнформационныхБаз.УникальныйИдентификаторИсточника = &УникальныйИдентификаторИсточника";
	//

	ЗапросСоответствияОбъектовИнформационныхБаз.УстановитьПараметр("УникальныйИдентификаторИсточника", ОбъектСсылка);

	РезультатЗапроса = ЗапросСоответствияОбъектовИнформационныхБаз.Выполнить();

	Если РезультатЗапроса.Пустой() Тогда
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'В регистре СоответствияОбъектовИнформационныхБаз
				|не найдены сведения для объекта ""%2"" (тип %3, уникальный идентификатор %4)).
				|Переход к сопоставленному объекту невозможен.
				|
				|Контекст ""%1""'",
				ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
			Контекст,
			Строка(ОбъектСсылка), ТипИсточника, УникальныйИдентификаторИсточника);
		ЗаписьЖурналаРегистрации("Переход к сопоставленному объекту. Сведения о сопоставлении не найдены",
			УровеньЖурналаРегистрации.Ошибка,
			Метаданные.НайтиПоТипу(ТипЗнч(ОбъектСсылка)), ОбъектСсылка,
			ТекстСообщения);
		ВызватьИсключение ТекстСообщения;
	КонецЕсли;
		
	Выборка = РезультатЗапроса.Выбрать();
	Выборка.Следующий();
	УникальныйИдентификаторПриемника = Выборка.УникальныйИдентификаторПриемника;
	ТипПриемника = Выборка.ТипПриемника;
	
	НавигационнаяСсылкаПриемника = ППСО_ОбменДаннымиКлиентСервер.ПолучитьНавигационнуюСсылкуСопоставленногоОбъектаПоРеквизитам(
		УникальныйИдентификаторПриемника, ТипПриемника, Выборка.ИмяСервера, Выборка.ИмяИнформационнойБазы); 

	ЗаписьЖурналаРегистрации("Переход к сопоставленному объекту",
		УровеньЖурналаРегистрации.Примечание,
		Метаданные.НайтиПоТипу(ТипЗнч(ОбъектСсылка)), ОбъектСсылка,
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'В регистре СоответствияОбъектовИнформационныхБаз
				|найдены сведения для объекта ""%2"" (тип %3, уникальный идентификатор %4):
				|сопоставлен объект с уникальным идентификатором %6 (тип %5).
				|
				|Навигационная ссылка сопоставленного объекта:
				|%7
				|
				|Контекст ""%1""'",
				ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
			Контекст,
			Строка(ОбъектСсылка), ТипИсточника, УникальныйИдентификаторИсточника,
			ТипПриемника, УникальныйИдентификаторПриемника,
			НавигационнаяСсылкаПриемника));

	Возврат НавигационнаяСсылкаПриемника;

КонецФункции

#КонецОбласти
