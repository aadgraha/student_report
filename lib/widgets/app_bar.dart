import 'package:flutter/material.dart';
import 'package:student_report/shared/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Laporan Belajar Siswa'.toUpperCase(),
                style: TextStyle(
                  fontSize: 22,
                  color: AppColors.appBarTextColor,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "SMK MA'AARIF 1 NANGGULAN",
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.appBarTextColor,
                ),
              ),
            ],
          ),
          Spacer(),
          SizedBox(
            height: 75,
            width: 75,
            child: Image.asset('assets/logo.png', fit: BoxFit.cover),
          ),
        ],
      ),
      toolbarHeight: toolbarHeight,
      backgroundColor: AppColors.appBarBgColor,
    );
  }

  static const toolbarHeight = 90.0;

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);
}
