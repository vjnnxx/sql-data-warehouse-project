===============================================================================
*/

-- ====================================================================
-- Verificando 'gold.dim_customers'
-- ====================================================================

-- Verificando singularidade de Customer Key em gold.dim_customers
-- Expectativa: sem resultados
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Verificando 'gold.product_key'
-- ====================================================================
-- Verificando singularidade de Customer Key em gold.dim_products
-- Expectativa: sem resultados
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Verificando 'gold.fact_sales'
-- ====================================================================

-- Verificando a conectividade do modelo de dados entre fato e dimensões
SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL  
