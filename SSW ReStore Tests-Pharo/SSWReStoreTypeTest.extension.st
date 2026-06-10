Extension { #name : 'SSWReStoreTypeTest' }

{ #category : '*SSW ReStore Tests-Pharo' }
SSWReStoreTypeTest >> testWideString [

	"Test storage of WideStrings"

	| wideString |
	
	wideString := 'caf€'.
	self assert: wideString class equals: WideString.
	self testStrings: wideString
]
