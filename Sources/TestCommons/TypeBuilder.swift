import SwiftAST
import Intentions
import KnownType

public class TypeBuilder<T: TypeGenerationIntention>: DeclarationBuilder<T> {
    var targetType: T
    
    public init(targetType: T) {
        self.targetType = targetType
    }
    
    @discardableResult
    public func addHistory(tag: String, description: String) -> TypeBuilder {
        targetType.history.recordChange(tag: tag, description: description)
        
        return self
    }
    
    @discardableResult
    public func createProperty(named name: String,
                               type: SwiftType,
                               attributes: [PropertyAttribute] = []) -> TypeBuilder {
        
        createProperty(named: name, type: type, mode: .asField, attributes: attributes)
    }
    
    @discardableResult
    public func createProperty(named name: String,
                               type: SwiftType,
                               mode: PropertyGenerationIntention.Mode = .asField,
                               attributes: [PropertyAttribute] = [],
                               builder: (MemberBuilder<PropertyGenerationIntention>) -> Void = emptyInit) -> TypeBuilder {
        
        let storage = ValueStorage(type: type, ownership: .strong, isConstant: false)
        
        let prop: PropertyGenerationIntention
        
        if targetType is ProtocolGenerationIntention {
            prop = ProtocolPropertyGenerationIntention(name: name,
                                                       storage: storage,
                                                       attributes: attributes)
        } else {
            prop = PropertyGenerationIntention(name: name,
                                               storage: storage,
                                               attributes: attributes)
        }
        
        prop.mode = mode
        
        let mbuilder = MemberBuilder(targetMember: prop)
        
        builder(mbuilder)
        
        targetType.addProperty(mbuilder.build())
        
        return self
    }
    
    @discardableResult
    public func createConstructor(withParameters parameters: [ParameterSignature] = [],
                                  builder: (MemberBuilder<InitGenerationIntention>) -> Void = emptyInit) -> TypeBuilder {
        
        let ctor = InitGenerationIntention(parameters: parameters)
        let mbuilder = MemberBuilder(targetMember: ctor)
        
        builder(mbuilder)
        
        targetType.addConstructor(mbuilder.build())
        
        return self
    }
    
    @discardableResult
    public func createVoidMethod(
        named name: String, builder: (MemberBuilder<MethodGenerationIntention>) -> Void = emptyInit) -> TypeBuilder {
        
        let signature = FunctionSignature(name: name, parameters: [])
        
        return createMethod(signature, builder: builder)
    }
    
    @discardableResult
    public func createMethod(named name: String,
                             returnType: SwiftType = .void,
                             parameters: [ParameterSignature] = [],
                             isStatic: Bool = false,
                             builder: (MemberBuilder<MethodGenerationIntention>) -> Void = emptyInit) -> TypeBuilder {
        
        let signature = FunctionSignature(name: name,
                                          parameters: parameters,
                                          returnType: returnType,
                                          isStatic: isStatic)
        
        return createMethod(signature, builder: builder)
    }
    
    @discardableResult
    public func createMethod(_ signatureString: String,
                             isStatic: Bool = false,
                             builder: (MemberBuilder<MethodGenerationIntention>) -> Void = emptyInit) -> TypeBuilder {
        
        var signature = try! FunctionSignatureParser.parseSignature(from: signatureString)
        signature.isStatic = isStatic
        
        return createMethod(signature, builder: builder)
    }
    
    @discardableResult
    public func createMethod(_ signature: FunctionSignature,
                             builder: (MemberBuilder<MethodGenerationIntention>) -> Void = emptyInit) -> TypeBuilder {
        
        let method: MethodGenerationIntention
        
        if targetType is ProtocolGenerationIntention {
            method = ProtocolMethodGenerationIntention(signature: signature)
        } else {
            method = MethodGenerationIntention(signature: signature)
        }
        
        if !(targetType is ProtocolGenerationIntention) {
            method.functionBody = FunctionBodyIntention(body: [])
        }
        
        let mbuilder = MemberBuilder(targetMember: method)
        builder(mbuilder)
        
        targetType.addMethod(mbuilder.build())
        
        return self
    }
    
    public func build() -> T {
        targetType
    }
}

public extension TypeBuilder where T: ClassExtensionGenerationIntention {
    
    /// Marks the target type for this type builder as an implementation for a
    /// category extension interface declaration.
    @discardableResult
    func setAsCategoryImplementation(categoryName: String) -> TypeBuilder {
        targetType.categoryName = categoryName
        
        return self
    }
    
}

public extension TypeBuilder where T: InstanceVariableContainerIntention {
    @discardableResult
    func createInstanceVariable(named name: String, type: SwiftType) -> TypeBuilder {
        let storage = ValueStorage(type: type, ownership: .strong, isConstant: false)
        
        let ivar = InstanceVariableGenerationIntention(name: name, storage: storage)
        targetType.addInstanceVariable(ivar)
        
        return self
    }
}

public extension TypeBuilder where T: BaseClassIntention {
    
    /// Marks the target type for this type builder as coming from an interface
    /// declaration.
    @discardableResult
    func setAsInterfaceSource() -> TypeBuilder {
        targetType.isInterfaceSource = true
        
        return self
    }
    
    /// Marks the target type for this type builder as coming from a category
    /// extension interface declaration.
    @discardableResult
    func setAsCategoryInterfaceSource() -> TypeBuilder {
        targetType.isInterfaceSource = true
        
        return self
    }
    
    @discardableResult
    func createConformance(protocolName: String) -> TypeBuilder {
        let prot = ProtocolInheritanceIntention(protocolName: protocolName)
        targetType.addProtocol(prot)
        
        return self
    }
    
    @discardableResult
    func createSynthesize(propertyName: String, variableName: String? = nil) -> TypeBuilder {
        let intent =
            PropertySynthesizationIntention(
                propertyName: propertyName,
                ivarName: variableName ?? propertyName,
                isExplicit: false,
                type: .synthesize)
        
        targetType.addSynthesization(intent)
        
        return self
    }
}

public extension TypeBuilder where T: ClassGenerationIntention {
    @discardableResult
    func inherit(from className: String) -> TypeBuilder {
        targetType.superclassName = className
        
        return self
    }
}

