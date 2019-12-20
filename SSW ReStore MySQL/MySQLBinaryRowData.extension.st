Extension { #name : #MySQLBinaryRowData }

{ #category : #'*SSW ReStore MySQL' }
MySQLBinaryRowData >> asSSWMySQLRowFrom: aDBQuery [

	^SSWMySQLRow newWithColumns: columnDescriptors data: columnValues query: aDBQuery
]
