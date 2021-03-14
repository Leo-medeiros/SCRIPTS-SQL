OPEN SYMMETRIC KEY MyKey_security 
DECRYPTION BY CERTIFICATE SQL_SECURITY WITH PASSWORD = 'pAA$$WOr6'

 DECLARE @GUID UNIQUEIDENTIFIER = (SELECT KEY_GUID('MyKey_security'))

 INSERT INTO usuarios VALUES ('emsdc\','tvt.leonardo.nsilva',ENCRYPTBYKEY(@GUID,'Tivit!@#'),14)
 GO



CLOSE SYMMETRIC KEY MyKey_security


select * from usuarios a
inner join clientes b on a.id_cliente = b.ID



