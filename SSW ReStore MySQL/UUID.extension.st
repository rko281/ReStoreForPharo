Extension { #name : 'UUID' }

{ #category : '*SSW ReStore MySQL' }
UUID >> forSSWMySQL [

	"MySQL stores the bytes"

	^self uuidData
]
