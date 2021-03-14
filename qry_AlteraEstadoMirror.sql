

IF (SELECT COUNT(*) FROM SYS.DATABASES WHERE recovery_model_desc = 'FULL') <>0
BEGIN

exec sp_msforeachdb @command1 = N' alter database [?] set recovery simple with no_wait'
END 




