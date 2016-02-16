import java.util.ArrayList;
import java.util.Arrays;

public class Main {
  // for diamonds
  int quadrant = 4;
  int direction = -1;
  ArrayList<Integer> quad0 = new ArrayList<Integer>(Arrays.asList(0, 1, 2, 4));
  ArrayList<Integer> quad1 = new ArrayList<Integer>(Arrays.asList(3, 6, 7, 10));
  ArrayList<Integer> quad2 = new ArrayList<Integer>(Arrays.asList(5, 8, 9, 12));
  ArrayList<Integer> quad3 = new ArrayList<Integer>(Arrays.asList(11, 13, 14, 15));

  void index2quaddir(int index) {
    if (quad0.contains(index)) {
      quadrant = 0;
      direction = quad0.indexOf(index);
    } else if (quad1.contains(index)) {
      quadrant = 1;
      direction = quad1.indexOf(index);
    } else if (quad2.contains(index)) {
      quadrant = 2;
      direction = quad2.indexOf(index);
    } else {
      assert quad3.contains(index);
      quadrant = 3;
      direction = quad3.indexOf(index);
    }
  }
}