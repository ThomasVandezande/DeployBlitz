DECLARE @dbname nvarchar(128)
SET @dbname = N'DBATools'

SELECT name 
FROM master.dbo.sysdatabases 
WHERE ('[' + name + ']' = @dbname 
OR name = @dbname)
