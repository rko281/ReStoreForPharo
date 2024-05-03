Extension { #name : 'MySQLResultSet' }

{ #category : '*SSW ReStore MySQL' }
MySQLResultSet >> asSSWMySQLResultSet [

	^SSWMySQLResultSet new
		statement: statement;
		nextResult: nextResult;
		header: header;
		fields: fields;
		fieldsEof: fieldsEof;
		rows: rows;
		rowsEof: rowsEof;
		yourself
]

{ #category : '*SSW ReStore MySQL' }
MySQLResultSet >> collect: aBlock [

	^self rows collect: aBlock
]
