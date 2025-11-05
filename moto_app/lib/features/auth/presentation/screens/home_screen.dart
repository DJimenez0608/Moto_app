import 'package:flutter/material.dart';
import 'package:moto_app/core/theme/app_colors.dart';
import 'package:moto_app/core/constants/app_constants.dart';
import 'package:animated_item/animated_item.dart';
import 'compare_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  int _currentTab = 1; // Home es el tab central

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildBody() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.pureBlack, AppColors.bluishGray],
          stops: [0.0, 0.7],
        ),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PageView con noticias
              SizedBox(
                height: 200,
                width: double.infinity,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return AnimatedPage(
                      controller: _pageController,
                      index: index,
                      effect: const FadeEffect(),
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        elevation: 4,
                        child: Center(
                          child: Text(
                            'Noticia ${index + 1}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              // Row con texto y botón
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Text(
                        'No sabes que moto comprar?',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkPurple,
                          foregroundColor: AppColors.pureWhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadius,
                            ),
                          ),
                        ),
                        child: const Text('comparar '),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Título Motos registradas
              Text(
                'Motos registradas:',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 10),
              // Card con datos de moto
              GestureDetector(
                onTap: () {},
                child: Card(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Container negro (foto moto)
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          height: 100,
                          margin: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: AppColors.pureBlack,
                            borderRadius: BorderRadius.all(
                              Radius.circular(AppConstants.borderRadius),
                            ),
                          ),
                        ),
                      ),
                      // Column con datos
                      Expanded(
                        flex: 55,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 6.0,
                            top: 10.0,
                            left: 6.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Yamaha R1',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Año: 2023',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                'Cilindrada: 998cc',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                'Potencia: 200hp',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                "Historial e mantenimientos",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 15),
              Card(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Container negro (foto moto)
                    Container(
                      //ICONO DE MANTENIMIENTO
                      width: MediaQuery.of(context).size.width * 0.1,
                      height: 40,
                      margin: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: AppColors.pureBlack,
                        borderRadius: BorderRadius.all(
                          Radius.circular(AppConstants.borderRadius),
                        ),
                      ),
                    ),

                    // Column con datos
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Descripcion del mantenimiento",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          "fecha del mantenimiento",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.darkPurple,
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Text(
                          "100.000 COP",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildMaintenanceCard(context),
              _buildMaintenanceCard(context),
              _buildMaintenanceCard(context),
              const SizedBox(height: 100), // Espacio para el bottom bar
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.pureBlack, AppColors.bluishGray],
              stops: [0.0, 0.7],
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hola, Nombre',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Bienvenido',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: AppColors.pureBlack,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentTab,
        children: [const CompareScreen(), _buildBody(), const ProfileScreen()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) {
          setState(() {
            _currentTab = index;
          });
        },
        backgroundColor: AppColors.bluishGray,
        selectedItemColor: AppColors.neonCyan,
        unselectedItemColor: AppColors.pureWhite,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.compare_arrows),
            label: 'Comparar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

Widget _buildMaintenanceCard(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(5.0),
    child: Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Container negro (foto moto)
          Container(
            //ICONO DE MANTENIMIENTO
            width: MediaQuery.of(context).size.width * 0.1,
            height: 40,
            margin: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: AppColors.pureBlack,
              borderRadius: BorderRadius.all(
                Radius.circular(AppConstants.borderRadius),
              ),
            ),
          ),

          // Column con datos
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Descripcion del mantenimiento",
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                "fecha del mantenimiento",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkPurple,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                "100.000 COP",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
