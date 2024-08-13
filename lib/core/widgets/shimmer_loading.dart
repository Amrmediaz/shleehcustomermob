import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shleehcustomer/core/util/Constants.dart';

class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({super.key});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> {
  @override
  Widget build(BuildContext context) {
    return  ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: const [
        LoadingItem(),
        LoadingItem(),
        LoadingItem(),

      ],
    );
  }
}

class LoadingItem extends StatelessWidget {
  const LoadingItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(15),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(DEFAULT_CORNER)),
          color: Colors.grey.shade300),
      height: 100,
      width: MediaQuery.of(context).size.width,
    );
  }
}

class ShimmerBoxLoading extends StatefulWidget {
  const ShimmerBoxLoading({super.key});

  @override
  State<ShimmerBoxLoading> createState() => _ShimmerBoxLoadingState();
}

class _ShimmerBoxLoadingState extends State<ShimmerBoxLoading> {
  @override
  Widget build(BuildContext context) {
    return  ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: const [
        LoadingBoxItem(),


      ],
    );
  }
}

class LoadingBoxItem extends StatelessWidget {
  const LoadingBoxItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(15),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(DEFAULT_CORNER)),
          color: Colors.grey.shade300),
      height: MediaQuery.of(context).size.width / 2,
      width: MediaQuery.of(context).size.width,
    );
  }
}