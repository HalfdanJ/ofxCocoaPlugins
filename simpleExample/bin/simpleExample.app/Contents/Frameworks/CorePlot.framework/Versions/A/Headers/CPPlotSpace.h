#import "CPDefinitions.h"
#import "CPResponder.h"

@class CPLayer;
@class CPPlotRange;
@class CPGraph;
@class CPPlotSpace;

extern NSString * const CPPlotSpaceCoordinateMappingDidChangeNotification;

/**	@brief Plot space delegate.
 **/
@protocol CPPlotSpaceDelegate <NSObject>

@optional

/// @name Scrolling
/// @{

/**	@brief Notifies that plot space is going to scroll.
 *	@param space The plot space.
 *  @param proposedDisplacementVector The proposed amount by which the plot space will shift
 *	@return The displacement actually applied.
 **/
-(CGPoint)plotSpace:(CPPlotSpace *)space willDisplaceBy:(CGPoint)proposedDisplacementVector;


/**	@brief Notifies that plot space is going to change a plot range.
 *	@param space The plot space.
 *  @param newRange The proposed new plot range.
 *  @param coordinate The coordinate of the range.
 *	@return The new plot range to be used.
 **/
-(CPPlotRange *)plotSpace:(CPPlotSpace *)space willChangePlotRangeTo:(CPPlotRange *)newRange forCoordinate:(CPCoordinate)coordinate;

/**	@brief Notifies that plot space has changed a plot range.
 *	@param space The plot space.
 *  @param coordinate The coordinate of the range.
 **/
-(void)plotSpace:(CPPlotSpace *)space didChangePlotRangeForCoordinate:(CPCoordinate)coordinate;

/// @}

@end

@interface CPPlotSpace : NSObject <CPResponder> {
	@private
    __weak CPGraph *graph;
	id <NSCopying, NSObject> identifier;
    __weak id <CPPlotSpaceDelegate> delegate;
    BOOL allowsUserInteraction;
}

@property (nonatomic, readwrite, copy) id <NSCopying, NSObject> identifier;
@property (nonatomic, readwrite, assign) BOOL allowsUserInteraction;
@property (nonatomic, readwrite, assign) __weak CPGraph *graph;
@property (nonatomic, readwrite, assign) __weak id <CPPlotSpaceDelegate> delegate;

@end

@interface CPPlotSpace(AbstractMethods)

/// @name Coordinate Space Conversions
/// @{
-(CGPoint)plotAreaViewPointForPlotPoint:(NSDecimal *)plotPoint;
-(CGPoint)plotAreaViewPointForDoublePrecisionPlotPoint:(double *)plotPoint;
-(void)plotPoint:(NSDecimal *)plotPoint forPlotAreaViewPoint:(CGPoint)point;
-(void)doublePrecisionPlotPoint:(double *)plotPoint forPlotAreaViewPoint:(CGPoint)point;
///	@}

/// @name Coordinate Range
/// @{
-(void)setPlotRange:(CPPlotRange *)newRange forCoordinate:(CPCoordinate)coordinate;
-(CPPlotRange *)plotRangeForCoordinate:(CPCoordinate)coordinate;
///	@}

/// @name Adjusting Ranges to Plot Data
/// @{
-(void)scaleToFitPlots:(NSArray *)plots;
///	@}

@end
