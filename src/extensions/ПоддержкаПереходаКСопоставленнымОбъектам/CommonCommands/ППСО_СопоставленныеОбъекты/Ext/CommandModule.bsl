﻿#Область ОбработчикиСобытий

&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	ПараметрыОтбора = Новый Структура("УникальныйИдентификаторИсточника", ПараметрКоманды);
	
	УзелИнформационнойБазы = ПолучитьУзелИнформационнойБазы();
	Если ЗначениеЗаполнено(УзелИнформационнойБазы) Тогда
		ПараметрыОтбора.Вставить("УзелИнформационнойБазы", УзелИнформационнойБазы);
	КонецЕсли;
	
	ПараметрыФормы = Новый Структура("Отбор", ПараметрыОтбора);
	
	ОткрытьФорму("РегистрСведений.СоответствияОбъектовИнформационныхБаз.ФормаСписка",
		ПараметрыФормы,
		ПараметрыВыполненияКоманды.Источник, ПараметрыВыполненияКоманды.Уникальность,
		ПараметрыВыполненияКоманды.Окно, ПараметрыВыполненияКоманды.НавигационнаяСсылка);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Функция ПолучитьУзелИнформационнойБазы()
	Контекст = "ППСО_СопоставленныеОбъекты.ПолучитьУзелИнформационнойБазы";
	
	ЗапросУзлаИнформационнойБазы = Новый Запрос;
	ЗапросУзлаИнформационнойБазы.Текст =
		"ВЫБРАТЬ ПЕРВЫЕ 1
	    |	ОбменБГУ2ЕМП.Ссылка КАК Ссылка
	    |ИЗ
	    |	ПланОбмена.ОбменБГУ2ЕМП КАК ОбменБГУ2ЕМП
	    |ГДЕ
	    |	НЕ( ОбменБГУ2ЕМП.ЭтотУзел )";

	РезультатЗапроса = ЗапросУзлаИнформационнойБазы.Выполнить();

	Если РезультатЗапроса.Пустой() Тогда
		Возврат ПланыОбмена.ОбменБГУ2ЕМП.ПустаяСсылка();
	Иначе
		Выборка = РезультатЗапроса.Выбрать();
		Выборка.Следующий();
		Возврат Выборка.Ссылка;
	КонецЕсли;
КонецФункции

#КонецОбласти
