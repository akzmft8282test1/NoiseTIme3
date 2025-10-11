admin_screen.dart


import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _groupIdController = TextEditingController();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Supabase Edge Function 호출
      final response = await Supabase.instance.client.functions.invoke(
        'send-group-notification', // 11단계에서 배포한 함수 이름
        body: {
          'group_id': _groupIdController.text,
          'title': _titleController.text,
          'body': _bodyController.text,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('알림 함수가 성공적으로 호출되었습니다.'), backgroundColor: Colors.green),
        );
      }

    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류 발생: $error'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _groupIdController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관리자 페이지'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('그룹 공지 알림 전송', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              TextFormField(
                controller: _groupIdController,
                decoration: const InputDecoration(labelText: 'Group ID'),
                validator: (value) => value == null || value.isEmpty ? 'Group ID를 입력하세요' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: '알림 제목 (Title)'),
                validator: (value) => value == null || value.isEmpty ? '제목을 입력하세요' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(labelText: '알림 내용 (Body)'),
                validator: (value) => value == null || value.isEmpty ? '내용을 입력하세요' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _sendNotification,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('전체 그룹 알림 전송'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "uri_does_not_exist",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/uri_does_not_exist",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "Target of URI doesn't exist: 'package:flutter/material.dart'.\nTry creating the file referenced by the URI, or try using a URI for a file that does exist.",
	"source": "dart",
	"startLineNumber": 2,
	"startColumn": 8,
	"endLineNumber": 2,
	"endColumn": 39
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "uri_does_not_exist",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/uri_does_not_exist",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "Target of URI doesn't exist: 'package:supabase_flutter/supabase_flutter.dart'.\nTry creating the file referenced by the URI, or try using a URI for a file that does exist.",
	"source": "dart",
	"startLineNumber": 3,
	"startColumn": 8,
	"endLineNumber": 3,
	"endColumn": 56
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "uri_does_not_exist",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/uri_does_not_exist",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "Target of URI doesn't exist: 'package:supabase_flutter/supabase_flutter.dart'.\nTry creating the file referenced by the URI, or try using a URI for a file that does exist.",
	"source": "dart",
	"startLineNumber": 3,
	"startColumn": 8,
	"endLineNumber": 3,
	"endColumn": 56
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "super_formal_parameter_without_associated_named",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/super_formal_parameter_without_associated_named",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "No associated named super constructor parameter.\nTry changing the name to the name of an existing named super constructor parameter, or creating such named parameter.",
	"source": "dart",
	"startLineNumber": 6,
	"startColumn": 28,
	"endLineNumber": 6,
	"endColumn": 31
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_class",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_class",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "Undefined class 'State'.\nTry changing the name to the name of an existing class, or creating a class with the name 'State'.",
	"source": "dart",
	"startLineNumber": 9,
	"startColumn": 3,
	"endLineNumber": 9,
	"endColumn": 8
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "extends_non_class",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/extends_non_class",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "Classes can only extend other classes.\nTry specifying a different superclass, or removing the extends clause.",
	"source": "dart",
	"startLineNumber": 12,
	"startColumn": 33,
	"endLineNumber": 12,
	"endColumn": 38
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_method",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_method",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The method 'TextEditingController' isn't defined for the type '_AdminScreenState'.\nTry correcting the name to the name of an existing method, or defining a method named 'TextEditingController'.",
	"source": "dart",
	"startLineNumber": 13,
	"startColumn": 30,
	"endLineNumber": 13,
	"endColumn": 51
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_method",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_method",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The method 'TextEditingController' isn't defined for the type '_AdminScreenState'.\nTry correcting the name to the name of an existing method, or defining a method named 'TextEditingController'.",
	"source": "dart",
	"startLineNumber": 14,
	"startColumn": 28,
	"endLineNumber": 14,
	"endColumn": 49
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_method",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_method",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The method 'TextEditingController' isn't defined for the type '_AdminScreenState'.\nTry correcting the name to the name of an existing method, or defining a method named 'TextEditingController'.",
	"source": "dart",
	"startLineNumber": 15,
	"startColumn": 27,
	"endLineNumber": 15,
	"endColumn": 48
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_method",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_method",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The method 'GlobalKey' isn't defined for the type '_AdminScreenState'.\nTry correcting the name to the name of an existing method, or defining a method named 'GlobalKey'.",
	"source": "dart",
	"startLineNumber": 16,
	"startColumn": 20,
	"endLineNumber": 16,
	"endColumn": 29
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "non_type_as_type_argument",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/non_type_as_type_argument",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The name 'FormState' isn't a type, so it can't be used as a type argument.\nTry correcting the name to an existing type, or defining a type named 'FormState'.",
	"source": "dart",
	"startLineNumber": 16,
	"startColumn": 30,
	"endLineNumber": 16,
	"endColumn": 39
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_method",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_method",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The method 'setState' isn't defined for the type '_AdminScreenState'.\nTry correcting the name to the name of an existing method, or defining a method named 'setState'.",
	"source": "dart",
	"startLineNumber": 24,
	"startColumn": 5,
	"endLineNumber": 24,
	"endColumn": 13
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_identifier",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_identifier",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "Undefined name 'Supabase'.\nTry correcting the name to one that is defined, or defining the name.",
	"source": "dart",
	"startLineNumber": 30,
	"startColumn": 30,
	"endLineNumber": 30,
	"endColumn": 38
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_identifier",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_identifier",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "Undefined name 'mounted'.\nTry correcting the name to one that is defined, or defining the name.",
	"source": "dart",
	"startLineNumber": 39,
	"startColumn": 11,
	"endLineNumber": 39,
	"endColumn": 18
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_identifier",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_identifier",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "Undefined name 'ScaffoldMessenger'.\nTry correcting the name to one that is defined, or defining the name.",
	"source": "dart",
	"startLineNumber": 40,
	"startColumn": 9,
	"endLineNumber": 40,
	"endColumn": 26
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_identifier",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_identifier",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "Undefined name 'context'.\nTry correcting the name to one that is defined, or defining the name.",
	"source": "dart",
	"startLineNumber": 40,
	"startColumn": 30,
	"endLineNumber": 40,
	"endColumn": 37
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "creation_with_non_type",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/creation_with_non_type",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The name 'SnackBar' isn't a class.\nTry correcting the name to match an existing class.",
	"source": "dart",
	"startLineNumber": 41,
	"startColumn": 17,
	"endLineNumber": 41,
	"endColumn": 25
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "creation_with_non_type",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/creation_with_non_type",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The name 'SnackBar' isn't a class.\nTry correcting the name to match an existing class.",
	"source": "dart",
	"startLineNumber": 41,
	"startColumn": 17,
	"endLineNumber": 41,
	"endColumn": 25
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "creation_with_non_type",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/creation_with_non_type",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The name 'SnackBar' isn't a class.\nTry correcting the name to match an existing class.",
	"source": "dart",
	"startLineNumber": 41,
	"startColumn": 17,
	"endLineNumber": 41,
	"endColumn": 25
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_identifier",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_identifier",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "Undefined name 'mounted'.\nTry correcting the name to one that is defined, or defining the name.",
	"source": "dart",
	"startLineNumber": 46,
	"startColumn": 11,
	"endLineNumber": 46,
	"endColumn": 18
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_identifier",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_identifier",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "Undefined name 'ScaffoldMessenger'.\nTry correcting the name to one that is defined, or defining the name.",
	"source": "dart",
	"startLineNumber": 47,
	"startColumn": 9,
	"endLineNumber": 47,
	"endColumn": 26
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_identifier",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_identifier",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "Undefined name 'context'.\nTry correcting the name to one that is defined, or defining the name.",
	"source": "dart",
	"startLineNumber": 47,
	"startColumn": 30,
	"endLineNumber": 47,
	"endColumn": 37
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_method",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_method",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The method 'SnackBar' isn't defined for the type '_AdminScreenState'.\nTry correcting the name to the name of an existing method, or defining a method named 'SnackBar'.",
	"source": "dart",
	"startLineNumber": 48,
	"startColumn": 11,
	"endLineNumber": 48,
	"endColumn": 19
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_method",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_method",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The method 'Text' isn't defined for the type '_AdminScreenState'.\nTry correcting the name to the name of an existing method, or defining a method named 'Text'.",
	"source": "dart",
	"startLineNumber": 48,
	"startColumn": 29,
	"endLineNumber": 48,
	"endColumn": 33
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_identifier",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_identifier",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "Undefined name 'Colors'.\nTry correcting the name to one that is defined, or defining the name.",
	"source": "dart",
	"startLineNumber": 48,
	"startColumn": 69,
	"endLineNumber": 48,
	"endColumn": 75
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_identifier",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_identifier",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "Undefined name 'mounted'.\nTry correcting the name to one that is defined, or defining the name.",
	"source": "dart",
	"startLineNumber": 52,
	"startColumn": 11,
	"endLineNumber": 52,
	"endColumn": 18
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_method",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_method",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The method 'setState' isn't defined for the type '_AdminScreenState'.\nTry correcting the name to the name of an existing method, or defining a method named 'setState'.",
	"source": "dart",
	"startLineNumber": 53,
	"startColumn": 9,
	"endLineNumber": 53,
	"endColumn": 17
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_super_member",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_super_member",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The method 'dispose' isn't defined in a superclass of '_AdminScreenState'.\nTry correcting the name to the name of an existing method, or defining a method named 'dispose' in a superclass.",
	"source": "dart",
	"startLineNumber": 65,
	"startColumn": 11,
	"endLineNumber": 65,
	"endColumn": 18
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_class",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_class",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "Undefined class 'Widget'.\nTry changing the name to the name of an existing class, or creating a class with the name 'Widget'.",
	"source": "dart",
	"startLineNumber": 69,
	"startColumn": 3,
	"endLineNumber": 69,
	"endColumn": 9
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_class",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_class",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "Undefined class 'BuildContext'.\nTry changing the name to the name of an existing class, or creating a class with the name 'BuildContext'.",
	"source": "dart",
	"startLineNumber": 69,
	"startColumn": 16,
	"endLineNumber": 69,
	"endColumn": 28
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_method",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_method",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The method 'Scaffold' isn't defined for the type '_AdminScreenState'.\nTry correcting the name to the name of an existing method, or defining a method named 'Scaffold'.",
	"source": "dart",
	"startLineNumber": 70,
	"startColumn": 12,
	"endLineNumber": 70,
	"endColumn": 20
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_method",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_method",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The method 'AppBar' isn't defined for the type '_AdminScreenState'.\nTry correcting the name to the name of an existing method, or defining a method named 'AppBar'.",
	"source": "dart",
	"startLineNumber": 71,
	"startColumn": 15,
	"endLineNumber": 71,
	"endColumn": 21
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "creation_with_non_type",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/creation_with_non_type",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The name 'Text' isn't a class.\nTry correcting the name to match an existing class.",
	"source": "dart",
	"startLineNumber": 72,
	"startColumn": 22,
	"endLineNumber": 72,
	"endColumn": 26
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_method",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_method",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The method 'Padding' isn't defined for the type '_AdminScreenState'.\nTry correcting the name to the name of an existing method, or defining a method named 'Padding'.",
	"source": "dart",
	"startLineNumber": 74,
	"startColumn": 13,
	"endLineNumber": 74,
	"endColumn": 20
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "creation_with_non_type",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/creation_with_non_type",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The name 'all' isn't a class.\nTry correcting the name to match an existing class.",
	"source": "dart",
	"startLineNumber": 75,
	"startColumn": 24,
	"endLineNumber": 75,
	"endColumn": 38
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_method",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_method",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The method 'Form' isn't defined for the type '_AdminScreenState'.\nTry correcting the name to the name of an existing method, or defining a method named 'Form'.",
	"source": "dart",
	"startLineNumber": 76,
	"startColumn": 16,
	"endLineNumber": 76,
	"endColumn": 20
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_method",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_method",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The method 'Column' isn't defined for the type '_AdminScreenState'.\nTry correcting the name to the name of an existing method, or defining a method named 'Column'.",
	"source": "dart",
	"startLineNumber": 78,
	"startColumn": 18,
	"endLineNumber": 78,
	"endColumn": 24
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_identifier",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_identifier",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "Undefined name 'CrossAxisAlignment'.\nTry correcting the name to one that is defined, or defining the name.",
	"source": "dart",
	"startLineNumber": 79,
	"startColumn": 33,
	"endLineNumber": 79,
	"endColumn": 51
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_method",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_method",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The method 'Text' isn't defined for the type '_AdminScreenState'.\nTry correcting the name to the name of an existing method, or defining a method named 'Text'.",
	"source": "dart",
	"startLineNumber": 81,
	"startColumn": 15,
	"endLineNumber": 81,
	"endColumn": 19
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_identifier",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_identifier",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "Undefined name 'Theme'.\nTry correcting the name to one that is defined, or defining the name.",
	"source": "dart",
	"startLineNumber": 81,
	"startColumn": 42,
	"endLineNumber": 81,
	"endColumn": 47
}]

[{
	"resource": "/home/user/noisetime/lib/screens/admin_screen.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "creation_with_non_type",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/creation_with_non_type",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The name 'SizedBox' isn't a class.\nTry correcting the name to match an existing class.",
	"source": "dart",
	"startLineNumber": 82,
	"startColumn": 21,
	"endLineNumber": 82,
	"endColumn": 29
}]

