"
ReStore
©2020 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBMultiValueCacheDictionaryEntry',
	#superclass : 'SSWDBCacheDictionaryEntry',
	#category : 'SSW ReStore Collections',
	#package : 'SSW ReStore Collections'
}

{ #category : 'actions' }
SSWDBMultiValueCacheDictionaryEntry >> addTargetTo: aCollection [

	(aCollection at: self key ifAbsentPut: [OrderedCollection new]) add: self target
]
