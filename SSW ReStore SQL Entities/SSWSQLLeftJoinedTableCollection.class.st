"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWSQLLeftJoinedTableCollection,
	#superclass : #SSWSQLJoinedTableCollection,
	#type : #variable,
	#category : #'SSW ReStore SQL Entities'
}

{ #category : #output }
SSWSQLLeftJoinedTableCollection >> writeSQLOn: aStream [

	self size = 1 ifTrue: [^super writeSQLOn: aStream].
	
	(self size - 1) timesRepeat: [aStream nextPut: $(].
	
	self first writeSQLOn: aStream.
	
	2 to: self size do:
		[ :index || nextTable join |
		nextTable := self at: index.
		join := self joinConditions at: (index - 1).
		aStream nextPutAll: ' LEFT JOIN '.
		nextTable writeSQLOn: aStream.
		aStream nextPutAll: ' ON '.
		join writeSQLOn: aStream.
		aStream nextPut: $)]
			
]
