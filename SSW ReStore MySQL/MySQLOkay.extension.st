Extension { #name : #MySQLOkay }

{ #category : #'*SSW ReStore MySQL' }
MySQLOkay >> asSSWMySQLResultSet [ 

	^SSWMySQLResultSet new
		rows: (1 to: affectedRows);
		yourself
]
