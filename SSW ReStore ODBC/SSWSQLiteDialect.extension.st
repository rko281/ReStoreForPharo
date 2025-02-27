Extension { #name : 'SSWSQLiteDialect' }

{ #category : '*SSW ReStore ODBC' }
SSWSQLiteDialect >> createNamespaceSQLFor: aString [

	"Since there is no filename given, map this to creating a temporary attached database"

	^'ATTACH DATABASE '''' AS ', (self asIdentifier: aString)
]

{ #category : '*SSW ReStore ODBC' }
SSWSQLiteDialect >> dropNamespaceSQLFor: aString [

	^'DETACH DATABASE ', (self asIdentifier: aString)
]

{ #category : '*SSW ReStore ODBC' }
SSWSQLiteDialect >> shouldRollbackOnQuery [

	"Seems to be required to avoid locking issues"

	^true
]

{ #category : '*SSW ReStore ODBC' }
SSWSQLiteDialect >> shouldUseColumnsStatement [

	"Under the SQLite ODBC driver ODBCColumnsStatement returns the character length for wide string columns, rather than the buffer length.
	Column details returned from a SELECT * query report the buffer length correctly"

	^false
]

{ #category : '*SSW ReStore ODBC' }
SSWSQLiteDialect >> tableNamesInNamespace: aString for: anODBCConnection [

	| stream table results |

	table := SSWDBTable new namespace: aString; name: 'sqlite_master'; yourself.
	stream := self sqlWriteStream.
	stream 
		nextPutAll: 'SELECT name FROM ';
		writeSQLFor: table;
		nextPutAll: ' WHERE type = ''table'''.

	results := anODBCConnection query: stream contents.

	^results collect: [ :each | each atIndex: 1]
]
