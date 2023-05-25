using Cinemachine;
using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class MapCreater : MonoBehaviour
{
    public string MapTemplateName;
    private BaseMapTemplate MapTemplate;
    public GameObject[] Floors;
    public GameObject[] ReplaceFloors;
    public GameObject MapHolder;
    private GameObject[,] Coords;


    private void Awake()
    {
        if (string.Equals("ExampleMapTemplate", MapTemplateName))
        {
            MapTemplate = new ExampleMapTemplate();
        }
        else
        {
            MapTemplate = new ExampleMapTemplate();
        }
        InitMap();
    }
    // Start is called before the first frame update
    void Start()
    {

        //InitMap();


    }

    // Update is called once per frame
    void Update()
    {

    }

    public GameObject[,] GetCoords()
    {
        return Coords;
    }
    public BaseMapTemplate GetMapTemplate()
    {
        return MapTemplate;
    }
    public void InitMap()
    {
        Coords = new GameObject[MapTemplate.XSize, MapTemplate.ZSize];
        for (int x = 0; x < MapTemplate.XSize; x++)
        {
            for (int z = 0; z < MapTemplate.ZSize; z++)
            {
                int index = UnityEngine.Random.Range(0, Floors.Length);
                GameObject child = Instantiate(
                    Floors[index],
                    new Vector3(x * MapTemplate.CubeSize, 0, z * MapTemplate.CubeSize),
                    Quaternion.identity);
                /*                Debug.Log("x"+(x * MapTemplate.CubeSize));
                                Debug.Log("y" + (MapTemplate.CubeSize / 2));
                                Debug.Log("z" + (z * MapTemplate.CubeSize));*/
                Coords[x, z] = child;
                child.transform.SetParent(MapHolder.transform);
            }
        }
        if (ReplaceFloors != null && ReplaceFloors.Length>0)
        {
            List<Coord> coords = MapTemplate.otherCubeCoords(Coords, ReplaceFloors);
            if (coords != null)
            {
                coords.ForEach(coord =>
                {
                    GameObject newObject = Instantiate(coord.ReplaceGameObject, Coords[coord.CoordX, coord.CoordZ].transform.position, coord.Rotation);
                    newObject.transform.SetParent(MapHolder.transform);
                    Destroy(Coords[coord.CoordX, coord.CoordZ]);
                    Coords[coord.CoordX, coord.CoordZ] = newObject;
                });
            }
        }

    }
}
