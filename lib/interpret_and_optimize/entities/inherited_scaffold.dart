import 'package:parabeac_core/design_logic/color.dart';
import 'package:parabeac_core/design_logic/design_node.dart';
import 'package:parabeac_core/eggs/injected_app_bar.dart';
import 'package:parabeac_core/eggs/injected_tab_bar.dart';
import 'package:parabeac_core/generation/generators/layouts/pb_scaffold_gen.dart';
import 'package:parabeac_core/generation/prototyping/pb_prototype_node.dart';
import 'package:parabeac_core/interpret_and_optimize/entities/alignments/injected_align.dart';
import 'package:parabeac_core/interpret_and_optimize/entities/layouts/temp_group_layout_node.dart';
import 'package:parabeac_core/interpret_and_optimize/entities/pb_shared_instance.dart';
import 'package:parabeac_core/interpret_and_optimize/entities/subclasses/pb_intermediate_node.dart';
import 'package:parabeac_core/interpret_and_optimize/entities/subclasses/pb_visual_intermediate_node.dart';
import 'package:parabeac_core/interpret_and_optimize/helpers/pb_context.dart';
import 'package:parabeac_core/interpret_and_optimize/value_objects/point.dart';

import 'interfaces/pb_inherited_intermediate.dart';

class InheritedScaffold extends PBVisualIntermediateNode
    with
        PBColorMixin
    implements
        /* with GeneratePBTree */ /* PropertySearchable,*/ PBInheritedIntermediate {
  @override
  var originalRef;
  @override
  PrototypeNode prototypeNode;

  var navbar;

  var tabbar;

  bool isHomeScreen = false;

  var body;

  InheritedScaffold(this.originalRef,
      {Point topLeftCorner,
      Point bottomRightCorner,
      String name,
      PBContext currentContext,
      this.isHomeScreen})
      : super(
            Point(originalRef.boundaryRectangle.x,
                originalRef.boundaryRectangle.y),
            Point(
                originalRef.boundaryRectangle.x +
                    originalRef.boundaryRectangle.width,
                originalRef.boundaryRectangle.y +
                    originalRef.boundaryRectangle.height),
            currentContext,
            name,
            UUID: originalRef.UUID ?? '') {
    if (originalRef is DesignNode && originalRef.prototypeNodeUUID != null) {
      prototypeNode = PrototypeNode(originalRef?.prototypeNodeUUID);
    }
    this.name = name
        ?.replaceAll(RegExp(r'[\W]'), '')
        ?.replaceFirst(RegExp(r'^([\d]|_)+'), '');

    generator = PBScaffoldGenerator();

    auxiliaryData.color = toHex(originalRef.backgroundColor);
  }

  @override
  List<PBIntermediateNode> layoutInstruction(List<PBIntermediateNode> layer) {
    return layer;
  }

  @override
  void addChild(PBIntermediateNode node) {
    if (node is PBSharedInstanceIntermediateNode) {
      if (node.originalRef.name.contains('<navbar>')) {
        navbar = node;
        return;
      }
      if (node.originalRef.name.contains('<tabbar>')) {
        tabbar = node;
        return;
      }
    }

    if (node is InjectedNavbar) {
      navbar = node;
      return;
    }
    if (node is InjectedTabBar) {
      tabbar = node;
      return;
    }

    if (child is TempGroupLayoutNode) {
      child.addChild(node);
      return;
    }
    // If there's multiple children add a temp group so that layout service lays the children out.
    if (child != null) {
      var temp = TempGroupLayoutNode(null, currentContext, node.name);
      temp.addChild(child);
      temp.addChild(node);
      child = temp;
    } else {
      child = node;
    }
  }

  @override
  void alignChild() {
    var align =
        InjectedAlign(topLeftCorner, bottomRightCorner, currentContext, '');
    align.addChild(child);
    align.alignChild();
    child = align;
  }
}
