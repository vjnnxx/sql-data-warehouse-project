-- ================================================
-- Quality check: crm_cust_info
-- ================================================

-- Verificar duplicatas ou nulls na chave primária
-- Expectativa: Sem resultados

USE DataWarehouse;

SELECT 
cst_id,
COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Procurar espaços indesejados
-- Expectativa: Sem resultados

SELECT 
cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname <> TRIM(cst_firstname);

-- Procurar espaços indesejados
-- Expectativa: Sem resultados

SELECT 
cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname <> TRIM(cst_lastname);

-- Procurar espaços indesejados
-- Expectativa: Sem resultados

SELECT 
cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr <> TRIM(cst_gndr);

-- Padronização de dados e consistência
SELECT 
DISTINCT cst_gndr
from silver.crm_cust_info;

SELECT 
DISTINCT cst_marital_status
from silver.crm_cust_info;

-- ================================================
-- Quality check: crm_prd_info
-- ================================================

-- Verificar duplicatas ou nulls na chave primária
-- Expectativa: Sem resultados

SELECT 
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;


-- Procurar espaços indesejados
-- Expectativa: Sem resultados

SELECT 
prd_nm
FROM silver.crm_prd_info
WHERE prd_nm <> TRIM(prd_nm);


-- Procurar por nulos ou números negativos
-- Expectativa: sem resultados

SELECT 
prd_cost
FROM silver.crm_prd_info 
WHERE prd_cost IS NULL OR prd_cost < 0

-- Padronização de dados e consistência
SELECT 
DISTINCT prd_line
from silver.crm_prd_info;

-- Buscar por datas de pedido inválidas

SELECT
*
FROM silver.crm_prd_info 
WHERE prd_start_dt > prd_end_dt;


-- ================================================
-- Quality check: crm_sales_details
-- ================================================

-- Verificar datas inválidas

SELECT 
	NULLIF(sls_due_dt, 0) sls_due_dt
FROM silver.crm_sales_details
WHERE 
sls_due_dt <= 0 
OR LEN(sls_due_dt) < 8 
OR sls_due_dt > 20500101
OR sls_due_dt < 19000101;

-- Verificar ordem inválida de datas

SELECT 
	*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;


-- Verificar consistência de dados entre: vendas, quantidade e preço
-- >> Sales = Quantity * Price
-- Valores não podem ser NULOS, zero ou negativos

-- Se as vendas forem negativas, zero ou nulas, utilizar preço e quantidade para calcular
-- Se o preco for negativo, calcular utilizando quantidade e vendas
-- Converter preços negativos para positivos

SELECT DISTINCT
	sls_sales,
	sls_quantity, 
	sls_price,

	CASE WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price)
	THEN sls_quantity * ABS(sls_price) 
	ELSE sls_sales END AS new_sales,
	
	CASE WHEN sls_price = 0 OR sls_price IS NULL
	THEN sls_sales/ NULLIF(sls_quantity, 0)
	WHEN sls_price < 0 THEN ABS(sls_price)
	ELSE sls_price END AS new_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <=0  OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;


-- ================================================
-- Quality check: erp_cust_az12
-- ================================================

-- Ajustando id para coincindir com tabela crm_cust_info

SELECT 
	cid,
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) 
	ELSE cid END AS new_cid
FROM bronze.erp_cust_az12;


-- Identificando datas incompatíveis

SELECT DISTINCT 
bdate 
FROM silver.erp_cust_az12 
WHERE bdate < '1924-01-01' OR bdate > GETDATE()


-- Padronização e consistência dos dados

SELECT  
	gen,
	CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE')
		THEN 'Female'
	WHEN UPPER(TRIM(gen)) IN ('M', 'MALE')
		THEN 'Male'
	ELSE 'n/a' END as new_gen
FROM silver.erp_cust_az12;

-- ================================================
-- Quality check: erp_loc_a101
-- ================================================


SELECT 
	cid, 
	REPLACE(cid, '-', '') cid,
	CASE WHEN TRIM(cntry) = 'DE' 
		THEN 'Germany'
	WHEN TRIM(cntry) IN ('USA', 'US')  
		THEN 'United States'
	WHEN cntry IS NULL OR cntry = '' 
		THEN 'n/a'
	ELSE cntry END AS cntry,
	cntry
FROM bronze.erp_loc_a101;


-- Padronização de dados e consistência

SELECT DISTINCT
cntry 
FROM silver.erp_loc_a101;

-- ================================================
-- Quality check: erp_px_cat_g1v2
-- ================================================

-- Verificando espaços indesejados

SELECT * FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);

-- Padronização de dados e consistência

SELECT DISTINCT maintenance FROM silver.erp_px_cat_g1v2;

