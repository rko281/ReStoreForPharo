Extension { #name : 'SQLite3Cursor' }

{ #category : '*SSW ReStore SQLite3' }
SQLite3Cursor >> asSSWSQLite3ResultSet [

	^SSWSQLite3ResultSet new
		statement: statement moreRows: moreRows rows: rows;
		yourself 
]
