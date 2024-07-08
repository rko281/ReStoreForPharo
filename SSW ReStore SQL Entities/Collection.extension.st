Extension { #name : 'Collection' }

{ #category : '*SSW ReStore SQL Entities' }
Collection >> writeSQLOn: aStream [

	self writeSQLOn: aStream with: [ :object | object writeSQLOn: aStream]
]

{ #category : '*SSW ReStore SQL Entities' }
Collection >> writeSQLOn: aStream forField: aField [

	self writeSQLOn: aStream with: [ :object | object writeSQLOn: aStream forField: aField]
]

{ #category : '*SSW ReStore SQL Entities' }
Collection >> writeSQLOn: aStream with: aBlock [

	"Private - Collections are comma-separated and parentheses-wrapped in SQL"
	
	aStream nextPut: $(.

	self 
		do: aBlock
		separatedBy: [aStream nextPut: $,].
	
	aStream nextPut: $)
]
