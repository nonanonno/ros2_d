@{
from rosidl_generator_d import  solve_depends, \
                                idl_type_to_d, \
                                assign_text_d_to_c, \
                                assign_text_c_to_d, \
                                array_init_text_d_to_c_with_semicolon, \
                                array_init_text_c_to_d_with_semicolon
                                
from rosidl_generator_c import  idl_structure_type_to_c_typename, \
                                idl_structure_type_sequence_to_c_typename
from rosidl_parser.definition import AbstractNestedType

this_module = (package_name, 'msg')
}@
@[for dep in solve_depends(contents, this_module)]@
import @('.'.join(dep));
@[end for]@

@[for content in contents]@
@{
namespaced_type = content.structure.namespaced_type
type_name = namespaced_type.name
c_type_name = idl_structure_type_to_c_typename(namespaced_type)
c_array_type_name = idl_structure_type_sequence_to_c_typename(namespaced_type)
typesupport_function = "rosidl_typesupport_c__get_message_type_support_handle__" + c_type_name
}@
struct @(type_name) {
    alias This = typeof(this);
    alias CMessageType = @(c_type_name);
    alias CArrayMessageType = @(c_array_type_name);

@[  for member in content.structure.members ]@
    @(idl_type_to_d(member.type)) @(member.name);
@[  end for]@
    
    static const(rosidl_message_type_support_t)* getTypesupport() @@nogc nothrow {
        return @(typesupport_function)();
    }

    static CMessageType* createCMessage() @@nogc nothrow {
        return @(c_type_name)__create();
    }

    static void destroyCMessage(ref CMessageType * msg) @@nogc nothrow {
        @(c_type_name)__destroy(msg);
        msg = null;
    }

    static CArrayMessageType *createCMessage(size_t size) @@nogc nothrow {
        return @(c_array_type_name)__create(size);
    }

    static destroyCMessage(ref CArrayMessageType * msg) @@nogc nothrow {
        @(c_array_type_name)__destroy(msg);
        msg = null;
    }

    static void convert(in This src, ref CMessageType dst) nothrow {
@[  for member in content.structure.members]@
@[    if isinstance(member.type, AbstractNestedType)]@
        @(array_init_text_d_to_c_with_semicolon(member, 'src.%s', 'dst.%s'))
        foreach(i; 0..src.@(member.name).length) {
            @(assign_text_d_to_c(member, 'src.%s[i]', 'dst.%s[i]'));
        }
@[    else]@
        @(assign_text_d_to_c(member, 'src.%s', 'dst.%s'));
@[    end if]@
@[  end for]@
    }

    static void convert(in CMessageType src, ref This dst) nothrow {
@[  for member in content.structure.members]@
@[    if isinstance(member.type, AbstractNestedType)]@
        @(array_init_text_c_to_d_with_semicolon(member, 'src.%s', 'dst.%s'))
        foreach(i; 0..dst.@(member.name).length) {
            @(assign_text_c_to_d(member, 'src.%s[i]', 'dst.%s[i]'));
        }
@[    else]@
        @(assign_text_c_to_d(member, 'src.%s', 'dst.%s'));
@[    end if]@
@[  end for]@
    }

}

@[end for]@