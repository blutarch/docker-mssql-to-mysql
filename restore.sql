-- Set the name of the Database to be created during the restore process
DECLARE @NewDatabaseName nvarchar(128) = 'ansysforums'

-- Set the location of the backup file with the .bak extension
DECLARE @TemplateBackups nvarchar(255) = '/hostvolume/backupfile.bak';

-- Get the backup file list as a table variable
DECLARE @BackupFiles TABLE(LogicalName nvarchar(128),PhysicalName nvarchar(260),Type char(1),FileGroupName nvarchar(128),Size numeric(20,0),MaxSize numeric(20,0),FileId tinyint,CreateLSN numeric(25,0),DropLSN numeric(25, 0),UniqueID uniqueidentifier,ReadOnlyLSN numeric(25,0),ReadWriteLSN numeric(25,0),BackupSizeInBytes bigint,SourceBlockSize int,FileGroupId int,LogGroupGUID uniqueidentifier,DifferentialBaseLSN numeric(25,0),DifferentialBaseGUID uniqueidentifier,IsReadOnly bit,IsPresent bit,TDEThumbprint varbinary(32), SnapshotUrl nvarchar(128));
INSERT @BackupFiles EXEC('RESTORE FILELISTONLY FROM DISK = ''' + @TemplateBackups +'''');

-- Extract the logical names to move
DECLARE @LogicalNameData VARCHAR(MAX), @LogicalNameLog VARCHAR(MAX);
SELECT @LogicalNameData = LogicalName FROM @BackupFiles WHERE Type = 'D';
SELECT @LogicalNameLog = LogicalName FROM @BackupFiles WHERE Type = 'L';

-- Prepare the location to move "Data" and "Log"
DECLARE @NewData varchar(MAX), @NewLog varchar(MAX);
set @NewData = '/var/opt/mssql/data/'+@NewDatabaseName+'_Data.mdf';
set @NewLog = '/var/opt/mssql/data/'+@NewDatabaseName+'_Log.mdf';

-- Restore the backup to DB name @NewDatabaseName, using the backup file provided by @TemplateBackups
RESTORE DATABASE @NewDatabaseName
FROM DISK=@TemplateBackups
WITH REPLACE,
MOVE @LogicalNameData TO @NewData,
MOVE @LogicalNameLog TO @NewLog