Extension { #name : #SSWDBTable }

{ #category : #'*SSW ReStore Main' }
SSWDBTable >> tableRecord [

	^SSWDBTableRecord new
		tableName: self name; 
		fullTableName: self fullName;
		nextID: 1;
		yourself
]

{ #category : #'*SSW ReStore Main' }
SSWDBTable >> versionControlField [

	^self controlFields detect: [ :each | each accessor specialSymbol = #_version]
]

{ #category : #'*SSW ReStore Main' }
SSWDBTable >> withIDAndVersionFields [

	"Return a copy of the receiver table but containing only the id and version fields"
	
	| withControlFields |

	withControlFields := SSWDBTable new.

	^withControlFields
		reStore: self reStore;
		name: self name;
		fullName: self fullName;
		idField: self idField;
		controlFields: (Array with: self versionControlField);
		yourself
]
