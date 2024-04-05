WITH
	mgef AS (
		SELECT
			STOFF as hazardous_material_number,
			SFNR1 as hazardous_substance_nr1,
			SFNR2 as hazardous_substance_nr2,
			SFNR3 as hazardous_substance_nr3,
			SFNR4 as hazardous_substance_nr4,
			LAGKL as storage_class,
			CASE WGFKL
				WHEN '0' THEN 'Not a water pollutant'
				WHEN '1' THEN 'Minimal water pollution danger'
				WHEN '2' THEN 'Water pollutant'
				WHEN '3' THEN 'Extreme water pollution danger'
				ELSE WGFKL
			END as water_pollution_class
		FROM
			"RXWSSTD"."products.wsstd.dv.p2r::DV_MGEF"
		WHERE 
			OPTYPE != 'D'
	),
	mara AS (
		SELECT
			MATNR as material_number,
			STOFF as hazardous_material_number,
			TEMPB as Temperature_conditions_indicator,
			RAUBE as storage_conditions,
			MTART as material_type
		FROM
			"RXWSSTD"."products.wsstd.dv.p2r::DV_MARA"
		WHERE 
			OPTYPE != 'D'
	),
	ekpo AS (
		SELECT 
			EBELN as purchasing_document_number,
			MATNR as material_number,
			TXZ01 as short_text,
			MENGE as purchase_order_quantity,
			MEINS as purchase_order_unit_of_measure,
			AFNAM as name_of_requester,
			WERKS as plant,
			ELIKZ as delivery_completed_indicator,
			LOEKZ as deletion_indicator_in_purchasing_document
		FROM
			"RXWSSTD"."products.wsstd.dv.p2r::DV_EKPO"
		WHERE
			WERKS = 'BYYL'
			AND OPTYPE != 'D'
	),
	eket AS (
		SELECT 
			EBELN as purchasing_document_number,
			EINDT as item_delivery_date,
			MENGE as scheduled_quantity
		FROM
			"RXWSSTD"."products.wsstd.dv.p2r::DV_EKET"
		WHERE
			EINDT >= '20200101'
			AND OPTYPE != 'D'
	),
	t142t AS (
		SELECT
			RAUBE as storage_conditions,
			RBTXT as description_of_storage_conditions
		FROM
			"RXWSSTD"."products.wsstd.dv.pmd::DV_T142T"
		WHERE
			SPRAS = 'D' 
			AND OPTYPE != 'D'
	),
	t143t AS (
		SELECT
			TEMPB as temperature_conditions_indicator,
			TBTXT as description_of_temperature_conditions
		FROM
			"RXWSSTD"."products.wsstd.dv.pmd::DV_T143T"
		WHERE 
			SPRAS = 'D' 
			AND OPTYPE != 'D'
	),
	t134t AS (
		SELECT
			MTART as material_type,
			MTBEZ as description_of_material_type
		FROM
			"RXWSSTD"."products.wsstd.dv.pmd::DV_T134T"
		WHERE
			SPRAS = 'D' 
			AND OPTYPE != 'D'
	)
SELECT DISTINCT
	ekpo.purchasing_document_number,
	ekpo.short_text,
	ekpo.purchase_order_quantity,
	ekpo.purchase_order_unit_of_measure,
	ekpo.name_of_requester,
	ekpo.delivery_completed_indicator,
	ekpo.plant,
	ekpo.deletion_indicator_in_purchasing_document,
	eket.item_delivery_date,
	eket.scheduled_quantity,
	mara.material_number,
	mara.hazardous_material_number,
	mara.temperature_conditions_indicator,
	t143t.description_of_temperature_conditions,
	mara.storage_conditions,
	t142t.description_of_storage_conditions,
	mara.material_type,
	t134t.description_of_material_type,
	mgef.hazardous_substance_nr1,
	mgef.hazardous_substance_nr2,
	mgef.hazardous_substance_nr3,
	mgef.hazardous_substance_nr4,
	mgef.storage_class,
	mgef.water_pollution_class

FROM

	ekpo
	JOIN eket ON ekpo.purchasing_document_number = eket.purchasing_document_number
	JOIN mara ON mara.material_number = ekpo.material_number
	JOIN mgef ON mgef.hazardous_material_number = mara.hazardous_material_number
	LEFT JOIN t142t ON mara.storage_conditions = t142t.storage_conditions
	LEFT JOIN t143t ON mara.temperature_conditions_indicator = t143t.temperature_conditions_indicator
	LEFT JOIN t134t ON mara.material_type = t134t.material_type
;
