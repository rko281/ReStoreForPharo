Extension { #name : #MySQLResultSet }

{ #category : #'*SSW ReStore MySQL' }
MySQLResultSet >> asSSWMySQLResultSet [

	^SSWMySQLResultSet new
		nextResult: nextResult;
		header: header;
		fields: fields;
		fieldsEof: fieldsEof;
		rows: (statement ifNil: [rows] ifNotNil: [ :stmt | rows collect: [ :each | each asSSWMySQLRowFrom: stmt query]]);
		rowsEof: rowsEof;
		statement: statement;
		yourself
]

{ #category : #'*SSW ReStore MySQL' }
MySQLResultSet >> collect: aBlock [

	^self rows collect: aBlock
]
