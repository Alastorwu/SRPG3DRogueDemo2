using System.Collections.Generic;
using UnityEngine;

public class BaseMapTemplate
{
    public int XSize { get; set; }
    public int ZSize { get; set; }

    public float CubeSize { get; set; }


    public void SetValues(int xSize, int zSize, float cubeSize)
    {
        XSize = xSize;
        ZSize = zSize;
        CubeSize = cubeSize;
    }

    public virtual List<Coord> otherCubeCoords(GameObject[,] xzCoords, GameObject[] replaceFloors) {
        return null;
    }
}