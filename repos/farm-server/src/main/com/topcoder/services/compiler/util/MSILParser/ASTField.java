/* Generated By:JJTree: Do not edit this line. ASTField.java */

package com.topcoder.services.compiler.util.MSILParser;

public class ASTField extends SimpleNode {
  public ASTField(int id) {
    super(id);
  }

  public ASTField(MSILParser p, int id) {
    super(p, id);
  }


  /** Accept the visitor. **/
  public Object jjtAccept(MSILParserVisitor visitor, Object data) {
    return visitor.visit(this, data);
  }
}