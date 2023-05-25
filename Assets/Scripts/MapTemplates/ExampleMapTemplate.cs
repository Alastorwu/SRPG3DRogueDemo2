using UnityEngine;
using System.Collections.Generic;
using System;
using System.Reflection;

public class ExampleMapTemplate : BaseMapTemplate
{

    public ExampleMapTemplate()
    {
        int xMultiple = UnityEngine.Random.Range(2, 3);
        int zMultiple = UnityEngine.Random.Range(2, 3);
        base.SetValues( 10* xMultiple, 10*zMultiple, 1);
    }

    public override List<Coord> otherCubeCoords(GameObject[,] xzCoords, GameObject[] replaceFloors)
    {
        List<Coord> coords = new List<Coord>();
        for (int i = 0; i < 10; i++) {
            List<Coord> coordsChild = otherCubeCoordsInner(xzCoords, replaceFloors);
            if (coordsChild==null || coordsChild.Count == 0) {
                continue;
            }
            coords.AddRange(coordsChild);
        }
        return coords;

    }

    private List<Coord> otherCubeCoordsInner(GameObject[,] xzCoords, GameObject[] replaceFloors) {
        List<Coord> coords = new List<Coord>();
        
        if (replaceFloors==null || replaceFloors.Length==0) {
            Debug.LogError("floor2ЮЊПе!");
            return null;
        }
        int xLen = xzCoords.GetLength(0);
        int zLen = xzCoords.GetLength(1);
        int xIndex = UnityEngine.Random.Range(0, xLen);
        int zIndex = UnityEngine.Random.Range(0, zLen);
        int index = UnityEngine.Random.Range(0, replaceFloors.Length);
        coords.Add(new Coord(replaceFloors[index], xIndex, zIndex, Quaternion.identity));
        return coords;

    }
}
