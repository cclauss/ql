namespace ns2 {
const int c = 1;
int v = 1;
int one() {return 1;}

void myNormalFunction()
{
	static int static_1 = 1;
	static int static_c = c;
	static int static_v = v;
	static int static_one = one();
	int local_1 = 1;
	int local_c = c;
	int local_v = v;
	int local_one = one();
}

template<class T> void myTemplateFunction()
{
	static int static_int_1 = 1;
	static int static_int_c = c; // [initializer is not populated]
	static int static_int_v = v; // [initializer is not populated]
	static int static_int_one = one(); // [initializer is not populated]
	static T static_t_1 = 1; // [initializer is not populated]
	static T static_t_c = c; // [initializer is not populated]
	static T static_t_v = v; // [initializer is not populated]
	static T static_t_one = one(); // [initializer is not populated]

	int local_int_1 = 1;
	int local_int_c = c;
	int local_int_v = v;
	int local_int_one = one();
	T local_t_1 = 1;
	T local_t_c = c;
	T local_t_v = v;
	T local_t_one = one();
}

template<class T> class myTemplateClass
{
public:
	void myMethod()
	{
		static int static_int_1 = 1;
		static int static_int_c = c; // [initializer is not populated]
		static int static_int_v = v; // [initializer is not populated]
		static int static_int_one = one(); // [initializer is not populated]
		static T static_t_1 = 1; // [initializer is not populated]
		static T static_t_c = c; // [initializer is not populated]
		static T static_t_v = v; // [initializer is not populated]
		static T static_t_one = one(); // [initializer is not populated]

		int local_int_1 = 1;
		int local_int_c = c;
		int local_int_v = v;
		int local_int_one = one();
		T local_t_1 = 1;
		T local_t_c = c;
		T local_t_v = v;
		T local_t_one = one();
	}
};

void testFunc()
{
	// instantiate the templates
	myTemplateFunction<int>();
	
	{
		myTemplateClass<int> mtc;
		mtc.myMethod();
	}
}
}
